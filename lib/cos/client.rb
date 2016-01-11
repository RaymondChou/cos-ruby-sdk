# coding: utf-8

require 'uri/http'

module COS

  class Client

    attr_reader :config, :api

    def initialize(options = {})
      @config = Config.new(options)
      @api    = API.new(@config)
      @cache_buckets = {}
    end

    # 获取鉴权签名方法
    def signature
      api.http.signature
    end

    # 指定bucket 初始化Bucket类
    def bucket(bucket_name = nil)
      unless @cache_buckets[bucket_name]
        # 缓存bucket对象
        @cache_buckets[bucket_name] = Bucket.new(self, bucket_name)
      end
      @cache_buckets[bucket_name]
    end

  end

  class Bucket

    include Logging

    attr_reader :client, :bucket_name, :authority, :bucket_type,
                :migrate_source_domain, :need_preview, :refers

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

      # 使用stat API 获取根目录信息可获取到bucket信息
      data = client.api.stat('/', bucket: bucket_name)
      @authority             = data[:authority]
      @bucket_type           = data[:bucket_type]
      @need_preview          = data[:need_preview]
      @refers                = data[:refers]
      @migrate_source_domain = data[:migrate_source_domain]
    end

    # 创建目录
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

    # 获取list中的文件及目录个数
    def list_count(path = '', options = {})
      options = {}
      result  = client.api.list(path, options.merge({num: 1, bucket: bucket_name}))
      total   = result[:filecount] + result[:dircount]

      {total: total, files: result[:filecount], dirs: result[:dircount]}
    end

    # 获取文件及目录总数
    def count(path = '')
      lc = list_count(path)
      lc[:total]
    end

    alias :size :count

    # 获取文件数
    def count_files(path = '')
      lc = list_count(path)
      lc[:files]
    end

    # 获取目录数
    def count_dirs(path = '')
      lc = list_count(path)
      lc[:dirs]
    end

    # 列出目录
    def list(path = '', options = {})
      Resource.new(self, path, options).to_enum
    end

    alias :ls :list

    # 上传文件, 大文件自动断点续传, 多线程上传
    # @return [COS::COSFile]
    def upload(path_or_dir, file_name, file_src, options = {}, &block)
      dir = get_dir(path_or_dir, options[:auto_create_folder])

      min_size    = options[:min_slice_size] || MIN_UPLOAD_SLICE_SIZE
      retry_times = options[:upload_retry] || DEFAULT_UPLOAD_RETRY

      options.merge!({bucket: bucket_name})

      file_size = File.size(file_src)

      retry_loop(retry_times) do
        if file_size > min_size
          # 分块上传
          client.api.upload_slice(dir.path, file_name, file_src, options, &block)
        else
          # 完整上传
          client.api.upload(dir.path, file_name, file_src, options)
        end
      end

      # 获取上传完成文件的状态, 只会返回<COSFile>
      stat(Util.get_list_path(dir.path, file_name, true))
    end

    # 上传目录下的全部文件(不包含子目录)
    def upload_all(path_or_dir, file_src_path, options = {}, &block)
      local_path = Util.get_local_path(file_src_path)
      uploaded = []

      Dir.foreach(local_path) do |file|
        if !file.start_with?('.') and !File.directory?(file)
          logger.info("Begin to upload file >> #{file}")
          begin
            uploaded << upload(path_or_dir, file, "#{local_path}/#{file}", options, &block)
          rescue => error
            if options[:skip_error]
              logger.info("#{file} error skipped")
              next
            else
              raise error
            end
          end
          logger.info("#{file} upload finished")
        end
      end

      uploaded
    end

    # 获取信息
    def stat(path = '')
      data = client.api.stat(path, bucket: bucket_name)

      # 查询'/'获取的是bucket信息, 无name参数, 需要补全
      data[:name] = '' if data[:name].nil?

      if data[:filesize].nil?
        # 目录
        COSDir.new(data.merge({bucket: self, path: path}))
      else
        # 文件
        COSFile.new(data.merge({bucket: self, path: path}))
      end
    end

    # 更新文件及目录业务属性
    def update(path, biz_attr)
      client.api.update(path, biz_attr, bucket: bucket_name)
    end

    # 删除文件或目录
    def delete(path)
      client.api.delete(path, bucket: bucket_name)
    end

    # 文件或目录是否存在
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

    # 判断文件是否上传完成
    def complete?(path)
      get_file(path).complete?
    end

    # 获取文件可访问的URL
    # 私有读取的bucket会自动生成带签名的URL
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

      if authority == 'eWRPrivate'
        # 私有读取的bucket自动生成带签名的URL
        sign = client.signature.multiple(bucket_name, options[:expire_seconds])
        "#{url}?sign=#{sign}"
      else
        url
      end
    end

    # 下载文件, 支持断点续传, 支持多线程
    def download(path_or_file, file_store, options = {}, &block)
      min_size    = options[:min_slice_size] || MIN_DOWNLOAD_SLICE_SIZE
      retry_times = options[:download_retry] || DEFAULT_DOWNLOAD_RETRY

      # 如果传入的是一个路径需要先获取文件信息
      file = get_file(path_or_file)

      # 检查文件是否上传完整才能下载
      if file.access_url.nil? and !file.complete?
        raise FileUploadNotComplete, 'file upload not complete'
      end

      # 检查本地文件sha1是否一致, 如一致就已下载完成了
      if File.exist?(file_store) and file.sha.upcase == Util.file_sha1(file_store).upcase
        logger.info("File #{file_store} exist and sha1 match, skip download.")
        return file_store
      end

      retry_loop(retry_times) do
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
      end

      # 返回本地文件路径
      file_store
    end

    # 下载目录下的全部文件(不包含子目录)
    def download_all(path_or_dir, file_store_path, options = {}, &block)
      local_path = Util.get_local_path(file_store_path)
      dir = get_dir(path_or_dir)
      downloaded = []
      # 遍历目录下的所有文件
      dir.list(pattern: :file_only).each do |file|
        logger.info("Begin to download file >> #{file.name}")
        downloaded << file.download("#{local_path}/#{file.name}", options, &block)
        logger.info("#{file.name} download finished")
      end
      downloaded
    end

    # 获取目录树形结构
    def tree(path_or_dir = '', options = {})
      dir = get_dir(path_or_dir)
      Tree.new(options.merge({path: dir})).to_object
    end

    private

    # 重试循环
    def retry_loop(retry_times, &block)
      begin
        block.call
      rescue => error
        if retry_times > 0
          retry_times -= 1
          logger.info('Retrying...')
          retry
        else
          raise error
        end
      end
    end

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
              "can't get file from #{path_or_file.class}, " \
              'must be a file path string or COS::COSFile'

      end
    end

    # 获取目录对象, 可接受path string或COSDir
    def get_dir(path_or_dir, auto_create_folder = false)
      if path_or_dir.is_a?(COS::COSDir)
        # 传入的是COSDir
        path_or_dir

      elsif path_or_dir.is_a?(String)
        # 传入的是path string
        path_or_dir = "#{path_or_dir}/" unless path_or_dir.end_with?('/')

        begin
          dir = stat(path_or_dir)
        rescue => error
          if auto_create_folder
            # 自动创建目录
            if error.is_a?(COS::ServerError) and error.error_code == -166
              logger.info('path not exist, auto create folder...')
              return create_folder(path_or_dir)
            end
          end

          raise error
        end

        get_dir(dir)

      else
        raise ClientError,
              "can't get dir from #{path_or_dir.class}, " \
              'must be a file path string or COS::COSDir'

      end
    end

  end

end