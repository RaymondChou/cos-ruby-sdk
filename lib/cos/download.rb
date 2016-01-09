# coding: utf-8

module COS

  # 大文件分片下载, 支持断点续传, 支持多线程
  # Range Headers support in HTTP1.1(rfc2616)
  class Download < Checkpoint

    include Logging

    # 默认分块大小
    PART_SIZE = 5 * 1024 * 1024

    # 默认文件读取大小
    READ_SIZE = 16 * 1024

    required_attrs :bucket, :cos_file, :file_store, :options
    optional_attrs :progress

    attr_accessor :cpt_file, :session

    def initialize(opts = {})
      super(opts)

      @cpt_file = options[:cpt_file] || "#{File.expand_path(file_store)}.cpt"
    end

    def download
      logger.info("Begin download, file: #{file_store}, threads: #{@num_threads}")

      # 重建断点续传
      rebuild

      # 文件分片
      divide_parts if @parts.empty?

      # 未完成的片段
      @todo_parts = @parts.reject { |p| p[:done] }

      # 多线程下载
      (1..@num_threads).map do
        logger.debug("#{@num_threads} Threads Downloads")

        Thread.new do
          logger.debug("Create Thread #{Thread.current.object_id}")

          loop do
            # 获取下一个未下载的片段
            p = sync_get_todo_part
            break unless p

            # 下载片段
            download_part(p)
          end
        end
      end.map(&:join)

      # 完成下载, 合并文件
      complete

      unless finish?
        File.delete(file_store) if File.exist?(file_store)
        raise DownloadError, 'File downloaded sha1 not match, deleted!'
      end
    end

    # 断点续传状态记录
    # @example
    #   states = {
    #     :session => 'session',
    #     :file => 'file',
    #     :file_meta => {
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

      parts = sync_get_all_parts
      states = {
          :session    => session,
          :file       => file_store,
          :file_meta  => @file_meta,
          :parts      => parts
      }

      done = parts.count { |p| p[:done] }

      # 上传进度回调
      if progress
        percent = done.to_f / parts.size
        progress.call(percent > 1 ? 1.to_f : percent)
      end

      write_checkpoint(states, cpt_file) unless options[:disable_cpt]

      logger.debug("Download Parts #{done}/#{parts.size}")
    end

    private

    # 是否完成下载并比对sha1
    def finish?
      @file_meta[:sha1].downcase == Util.file_sha1(@file_store)
    end

    def complete
      # 返回100%的进度
      progress.call(1.to_f) if progress

      # 获取全部的分块
      parts = sync_get_all_parts

      # 合并分块文件
      File.open(@file_store, 'w') do |w|
        # 排序组合文件
        parts.sort{ |x, y| x[:number] <=> y[:number] }.each do |p|
          File.open(get_part_file(p)) do |r|
            w.write(r.read(READ_SIZE)) until r.eof?
          end
        end
      end

      # 下载完成, 删除checkpoint文件
      File.delete(cpt_file) unless options[:disable_cpt]
      # 删除分块文件
      parts.each{ |p| File.delete(get_part_file(p)) }

      logger.info("Done download, file: #{@file_store}")
    end

    # 断点续传文件重建
    def rebuild
      logger.info("Begin rebuild session, checkpoint: #{cpt_file}")

      # 是否启用断点续传并且记录文件存在
      if options[:disable_cpt] || !File.exist?(cpt_file)
        # 初始化
        initiate
      else
        # 加载断点续传
        states = load_checkpoint(cpt_file)

        @session    = states[:session]
        @file_meta  = states[:file_meta]
        @parts      = states[:parts]
      end

      logger.info("Done rebuild session, Parts: #{@parts.count}")
    end

    def initiate
      logger.info('Begin initiate session')

      @session = "#{cos_file.bucket.bucket_name}-#{cos_file.path}-#{Time.now.to_i}"

      @file_meta = {
          :sha1  => cos_file.sha,
          :size  => cos_file.filesize
      }

      # 保存断点
      checkpoint

      logger.info("Done initiate session: #{@session}")
    end

    # 下载片段
    def download_part(p)
      logger.debug("Begin download slice: #{p}")

      part_file = get_part_file(p)

      url = cos_file.url

      # 下载
      # Range:bytes=0-11
      bucket.client.api.download(
          url,
          part_file,
          headers: {Range: "bytes=#{p[:range].at(0)}-#{p[:range].at(1) - 1}"},
          bucket: bucket.bucket_name
      )

      sync_update_part(p.merge(done: true))

      checkpoint

      logger.debug("Done download part: #{p}")
    end

    # 文件片段拆分
    def divide_parts
      logger.info("Begin divide parts, file: #{file_store}")

      object_size = @file_meta[:size]
      part_size   = @options[:part_size] || PART_SIZE
      num_parts   = (object_size - 1) / part_size + 1

      @parts = (1..num_parts).map do |i|
        {
            :number => i,
            :range => [(i - 1) * part_size, [i * part_size, object_size].min],
            :done => false
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

    # 获取分块文件名
    def get_part_file(p)
      "#{@file_store}.part.#{p[:number]}"
    end

  end

end