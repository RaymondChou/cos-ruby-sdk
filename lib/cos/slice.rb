# coding: utf-8

require 'tempfile'

module COS

  # 分片大文件上传, 支持断点续传, 支持多线程
  class Slice < Checkpoint

    include Logging

    # 默认分片大小 3M
    DEFAULT_SLICE_SIZE = 3 * 1024 * 1024

    required_attrs :config, :http, :path, :file_name, :file_src, :options
    optional_attrs :progress

    attr_accessor :cpt_file, :result, :offset, :slice_size, :session

    def initialize(opts = {})
      super(opts)

      @cpt_file = options[:cpt_file] || "#{File.expand_path(file_src)}.cpt"
    end

    # 开始上传
    def upload
      logger.info("Begin upload, file: #{file_src}, threads: #{@num_threads}")

      # 重建断点续传或重新从服务器初始化分片上传
      # 有可能sha命中直接完成
      data = rebuild
      return data if data

      # 文件分片
      divide_parts if @parts.empty?

      # 未完成的片段
      @todo_parts = @parts.reject { |p| p[:done] }

      begin
        # 多线程上传
        (1..@num_threads).map do
          Thread.new do
            loop do
              # 获取下一个未上传的片段
              p = sync_get_todo_part
              break unless p

              # 上传片段
              upload_part(p)
            end
          end
        end.map(&:join)
      rescue => error
        unless finish?
          # 部分服务端异常需要重新初始化, 可能上传已经完成了
          if error.is_a?(ServerError) and error.error_code == -288
            File.delete(cpt_file) unless options[:disable_cpt]
          end
          raise error
        end
      end

      # 返回100%的进度
      progress.call(1.to_f) if progress

      # 上传完成, 删除checkpoint文件
      File.delete(cpt_file) unless options[:disable_cpt]

      logger.info("Done upload, file: #{@file_src}")

      # 返回文件信息
      result
    end

    # 断点续传状态记录
    # @example
    #   states = {
    #     :session => 'session',
    #     :offset => 0,
    #     :slice_size => 2048,
    #     :file => 'file',
    #     :file_meta => {
    #       :mtime => Time.now,
    #       :sha1 => 'file sha1',
    #       :size => 10000,
    #     },
    #     :parts => [
    #       {:number => 1, :range => [0, 100], :done => false},
    #       {:number => 2, :range => [100, 200], :done => true}
    #     ],
    #     :sha1 => 'checkpoint file sha1'
    #   }
    def checkpoint
      logger.debug("Make checkpoint, options[:disable_cpt]: #{options[:disable_cpt] == true}")

      ensure_file_not_changed

      parts = sync_get_all_parts
      states = {
          :session    => session,
          :slice_size => slice_size,
          :offset     => offset,
          :file       => file_src,
          :file_meta  => @file_meta,
          :parts      => parts
      }

      done = parts.count { |p| p[:done] }

      # 上传进度回调
      if progress
        percent = (offset + done*slice_size).to_f / states[:file_meta][:size]
        progress.call(percent > 1 ? 1.to_f : percent)
      end

      write_checkpoint(states, cpt_file) unless options[:disable_cpt]

      logger.debug("Upload Parts #{done}/#{states[:parts].count}")
    end

    private

    # 是否完成上传
    def finish?
      result != nil and result[:access_url] != nil
    end

    # 断点续传文件重建
    def rebuild
      logger.info("Begin rebuild session, checkpoint: #{cpt_file}")

      # 是否启用断点续传并且记录文件存在
      if options[:disable_cpt] || !File.exist?(cpt_file)
        # 从服务器初始化
        data = initiate
        return data if data
      else
        # 加载断点续传
        states = load_checkpoint(cpt_file)

        # 确保上传的文件未变化
        if states[:file_sha1] != @file_meta[:sha1]
          raise FileInconsistentError, 'The file to upload is changed'
        end

        @session    = states[:session]
        @file_meta  = states[:file_meta]
        @parts      = states[:parts]
        @slice_size = states[:slice_size]
        @offset     = states[:offset]
      end

      logger.info("Done rebuild session, Parts: #{@parts.count}")

      false
    end

    # 初始化分块上传
    def initiate
      logger.info('Begin initiate session')

      bucket        = config.get_bucket(options[:bucket])
      sign          = http.signature.multiple(bucket)
      resource_path = Util.get_resource_path(config.app_id, bucket, path, file_name)
      file_size     = File.size(file_src)
      file_sha1     = Util.file_sha1(file_src)

      payload = {
          op:          'upload_slice',
          slice_size:  options[:slice_size] || DEFAULT_SLICE_SIZE,
          sha:         file_sha1,
          filesize:    file_size,
          biz_attr:    options[:biz_attr],
          session:     session,
          multipart:   true
      }

      resp = http.post(resource_path, {}, sign, payload)

      # 上一次已传完或秒传成功
      return resp if resp[:access_url]

      @session    = resp[:session]
      @slice_size = resp[:slice_size]
      @offset     = resp[:offset]

      @file_meta = {
          :mtime => File.mtime(file_src),
          :sha1  => file_sha1,
          :size  => file_size
      }

      # 保存断点
      checkpoint

      logger.info("Done initiate session: #{@session}")

      false
    end

    # 上传块
    def upload_part(p)
      logger.debug("Begin upload slice: #{p}")

      bucket        = config.get_bucket(options[:bucket])
      sign          = http.signature.multiple(bucket)
      resource_path = Util.get_resource_path(config.app_id, bucket, path, file_name)
      temp_file     = Tempfile.new("#{session}-#{p[:number]}")

      begin
        # 复制文件分片至临时文件
        IO.copy_stream(file_src, temp_file, p[:range].at(1) - p[:range].at(0), p[:range].at(0))

        payload = {
            op:          'upload_slice',
            sha:         Util.file_sha1(temp_file),
            offset:      p[:range].at(0),
            session:     session,
            filecontent: temp_file,
            multipart:   true
        }

        re = http.post(resource_path, {}, sign, payload)
        @result = re if re[:access_url]
      ensure
        # 确保清除临时文件
        temp_file.close
        temp_file.unlink
      end

      sync_update_part(p.merge(done: true))

      checkpoint

      logger.debug("Done upload part: #{p}")
    end

    # 文件片段拆分
    def divide_parts
      logger.info("Begin divide parts, file: #{file_src}")

      file_size = File.size(file_src)
      num_parts = (file_size - offset - 1) / slice_size + 1
      @parts = (1..num_parts).map do |i|
        {
            :number => i,
            :range  => [offset + (i-1) * slice_size, [offset + i * slice_size, file_size].min],
            :done   => false
        }
      end

      checkpoint

      logger.info("Done divide parts, parts: #{@parts.size}")
    end

    # 同步获取下一片段
    def sync_get_todo_part
      @todo_mutex.synchronize {
        @todo_parts.shift
      }
    end

    # 同步更新片段
    def sync_update_part(p)
      @all_mutex.synchronize {
        @parts[p[:number] - 1] = p
      }
    end

    # 同步获取所有片段
    def sync_get_all_parts
      @all_mutex.synchronize {
        @parts.dup
      }
    end

    # 确保上传中文件没有变化
    def ensure_file_not_changed
      return if File.mtime(file_src) == @file_meta[:mtime]

      if @file_meta[:sha1] != Util.file_sha1(file_src)
        # p Util.file_sha1(file_src)
        raise FileInconsistentError, 'The file to upload is changed'
      end
    end

  end

end