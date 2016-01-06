module COS

  class Client

    attr_reader :config, :api

    def initialize(options = {})
      @config = Config.new(options)
      @api    = API.new(@config)
    end

    def signature
      api.http.signature
    end

    def bucket(bucket_name)
      Bucket.new(self, bucket_name)
    end

  end

  class Bucket

    include Logging

    attr_reader :client, :bucket_name

    MIN_SLICE_SIZE = 10 * 1024 * 1024
    DEFAULT_UPLOAD_RETRY = 10

    def initialize(client, bucket_name)
      @client      = client
      @bucket_name = bucket_name
    end

    def create_folder(path, options = {})
      data = client.api.create_folder(path, options.merge({bucket: bucket_name}))
      path = Util.get_list_path(path)
      dir  = {
          mtime:    data[:mtime],
          ctime:    data[:ctime],
          name:     path.split('/').last(1),
          biz_attr: options[:biz_attr],
          bucket:   self,
          path:     path
      }

      COSDir.new(dir)
    end

    alias :mkdir :create_folder

    def list_count(path = '', options = {})
      options = {}
      result  = client.api.list(path, options.merge({num: 1, bucket: bucket_name}))
      total   = result[:filecount] + result[:dircount]

      {total: total, files: result[:filecount], dirs: result[:dircount]}
    end

    def count(path = '', options = {})
      lc = list_count(path, options)
      lc[:total]
    end

    alias :size :count

    def list(path = '', options = {})
      Resource.new(self, path, options).to_enum
    end

    alias :ls :list

    # @return [COS::COSFile]
    def upload(path, file_name, file_src, options = {}, &block)
      min = options[:min_slice_size] || MIN_SLICE_SIZE
      retry_times = options[:upload_retry] || DEFAULT_UPLOAD_RETRY

      options.merge!({bucket: bucket_name})

      file_size = File.size(file_src)
      begin
        if file_size > min
          # 分块上传
          client.api.upload_slice(path, file_name, file_src, options, &block)
        else
          # 完整上传
          client.api.upload(path, file_name, file_src, options)
        end
      rescue => error
        if retry_times > 0
          logger.warn(error)
          retry_times -= 1
          retry
        else
          raise error
        end
      end

      # 获取上传完成文件的状态, 只会返回<COSDir>
      stat(Util.get_list_path(path, file_name, true))
    end

    def stat(path)
      data = client.api.stat(path, bucket: bucket_name)

      if data[:filesize].nil?
        # 目录
        COSDir.new(data.merge({bucket: self, path: path}))
      else
        # 文件
        COSFile.new(data.merge({bucket: self, path: path}))
      end
    end

    def update(path, biz_attr)
      client.api.update(path, biz_attr, bucket: bucket_name)
    end

    def delete(path)
      client.api.delete(path, bucket: bucket_name)
    end

    def exist?(path)
      begin
        stat(path)
      rescue ServerError => e
        return false if e.error_code == -166
        raise e
      end

      true
    end

    alias :exists? :exist?

  end

end