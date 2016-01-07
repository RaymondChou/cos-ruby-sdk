require 'uri/http'

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

    # 指定bucket 初始化Bucket类
    def bucket(bucket_name = nil)
      Bucket.new(self, bucket_name)
    end

  end

  class Bucket

    include Logging

    attr_reader :client, :bucket_name

    # 最小上传分块大小
    MIN_UPLOAD_SLICE_SIZE   = 10 * 1024 * 1024

    # 最小下载分块大小
    MIN_DOWNLOAD_SLICE_SIZE = 5 * 1024 * 1024

    # 默认上传重试次数
    DEFAULT_UPLOAD_RETRY    = 10

    # 默认下载重试次数
    DEFAULT_DOWNLOAD_RETRY  = 10

    def initialize(client, bucket_name = nil)
      @client      = client
      @bucket_name = client.config.get_bucket(bucket_name)
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
      min_size    = options[:min_slice_size] || MIN_UPLOAD_SLICE_SIZE
      retry_times = options[:upload_retry] || DEFAULT_UPLOAD_RETRY

      options.merge!({bucket: bucket_name})

      file_size = File.size(file_src)
      begin
        if file_size > min_size
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

    # 获取文件可访问的URL
    def url(path_or_file, options = {})

      file = get_file(path_or_file)

      url = file.access_url

      # 使用cname
      if options[:cname]
        host = URI.parse(url).host.downcase
        url.gsub!(host, options[:cname])
      end

      # 使用https
      if options[:https]
        url.gsub!('http://', 'https://')
      end

      url
    end

    # 下载文件, 支持断点续传, 支持多线程
    def download(path_or_file, file_store, options = {}, &block)
      min_size    = options[:min_slice_size] || MIN_DOWNLOAD_SLICE_SIZE
      retry_times = options[:download_retry] || DEFAULT_DOWNLOAD_RETRY

      # 如果传入的是一个路径需要先获取文件信息
      file = get_file(path_or_file)

      # 检查文件是否上传完整才能下载
      unless file.access_url or file.complete?
        raise FileUploadNotComplete, 'file upload not complete'
      end

      begin
        if file.filesize > min_size
          # 分块下载
          Download.new(
              bucket:     self,
              cos_file:   file,
              file_store: file_store,
              options:    options,
              progress:   block
          ).download

        else
          # 直接下载
          client.api.download(file.access_url, file_store, bucket: bucket_name)

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

      # 返回本地文件路径
      file_store
    end

    private

    # 获取文件对象, 可接受path string或COSFile
    def get_file(path_or_file)
      if path_or_file.is_a?(COS::COSFile)
        # 传入的是COSFile
        path_or_file

      elsif path_or_file.is_a?(String)
        # 传入的是path string
        file = stat(path_or_file)
        get_file(file)

      else
        raise ClientError,
              "can't get file from#{path_or_file.class}, " \
              'must be a file path string or COS::COSFile'

      end
    end

  end

end