# coding: utf-8

require 'uri'

module COS

  class Bucket

    include Logging

    attr_reader :client, :bucket_name, :authority, :bucket_type,
                :migrate_source_domain, :need_preview, :refers,
                :blackrefers, :brower_exec, :cnames, :nugc_flag

    # 最小完整上传大小
    MIN_UPLOAD_SLICE_SIZE   = 10 * 1024 * 1024

    # 最小下载分块大小
    MIN_DOWNLOAD_SLICE_SIZE = 5 * 1024 * 1024

    # 默认上传重试次数
    DEFAULT_UPLOAD_RETRY    = 10

    # 默认下载重试次数
    DEFAULT_DOWNLOAD_RETRY  = 10

    # 初始化
    #
    # @note SDK会自动获取bucket的信息,包括读取权限等并进行缓存
    #  如需在后台修改了bucket信息请重新初始化Client
    #
    # @param client [COS::Client]
    # @param bucket_name [String] bucket名称
    #  如果在初始化时的配置中设置了default_bucket则该字段可以为空,会获取默认的bucket
    #
    # @return [COS::Bucket]DEFAULT_UPLOAD_RETRY
    #
    # @raise [ClientError] 未指定bucket
    # @raise [ServerError] bucket不存在
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
      @blackrefers           = data[:blackrefers]
      @brower_exec           = data[:brower_exec]
      @cnames                = data[:cnames]
      @nugc_flag             = data[:nugc_flag]
    end

    # 创建目录
    #
    # @see API#create_folder
    #
    # @param path [String] 目录路径, 如: 'path1', 'path1/path2', sdk会补齐末尾的 '/'
    # @param options [Hash] 高级参数
    # @option options [String] :biz_attr 目录属性, 业务端维护
    #
    # @return [COS::COSDir]
    #
    # @raise [ServerError] 服务端异常返回
    def create_folder(path, options = {})
      data = client.api.create_folder(path, options.merge({bucket: bucket_name}))
      dir  = {
          mtime:    data[:mtime],
          ctime:    data[:ctime],
          name:     data[:name],
          biz_attr: options[:biz_attr],
          bucket:   self,
          path:     path
      }

      COSDir.new(dir)
    end

    alias :mkdir :create_folder

    # 获取list中的文件及目录个数
    #
    # @param path [String] 目录路径, 如: 'path1', 'path1/path2', sdk会补齐末尾的 '/'
    #
    # @param options [Hash]
    # @option options [String] :prefix 搜索前缀
    #  如果填写prefix, 则计算含此前缀的所有文件及目录个数
    #
    # @return [Hash]
    #  * :total [Integer] 文件和目录总数
    #  * :files [Integer] 文件数
    #  * :dirs [Integer] 目录数
    #
    # @raise [ServerError] 服务端异常返回
    def list_count(path = '', options = {})
      options = {}
      result  = client.api.list(path, options.merge({num: 1, bucket: bucket_name}))
      total   = result[:filecount] + result[:dircount]

      {total: total, files: result[:filecount], dirs: result[:dircount]}
    end

    # 获取文件及目录总数
    #
    # @param path [String] 目录路径, 如: 'path1', 'path1/path2', sdk会补齐末尾的 '/'
    #
    # @return [Integer] 文件及目录总数
    #
    # @raise [ServerError] 服务端异常返回
    def count(path = '')
      lc = list_count(path)
      lc[:total]
    end

    alias :size :count

    # 获取文件数
    #
    # @param path [String] 目录路径, 如: 'path1', 'path1/path2', sdk会补齐末尾的 '/'
    #
    # @return [Integer] 文件数
    #
    # @raise [ServerError] 服务端异常返回
    def count_files(path = '')
      lc = list_count(path)
      lc[:files]
    end

    # 获取目录数
    #
    # @param path [String] 目录路径, 如: 'path1', 'path1/path2', sdk会补齐末尾的 '/'
    #
    # @return [Integer] 目录数
    #
    # @raise [ServerError] 服务端异常返回
    def count_dirs(path = '')
      lc = list_count(path)
      lc[:dirs]
    end

    # 列出目录
    #
    # @param path [String] 目录路径, 如: '/', 'path1', 'path1/path2', sdk会补齐末尾的 '/'
    # @param options [Hash]
    # @option options [String] :prefix 搜索前缀
    #  如果填写prefix, 则列出含此前缀的所有文件及目录
    # @option options [Integer] :num 每页拉取的数量, 默认20条
    # @option options [Symbol] :pattern 获取方式
    #  :dir_only 只获取目录, :file_only 只获取文件, 默认为 :both 全部获取
    # @option options [Symbol] :order 排序方式 :asc 正序, :desc 倒序 默认为 :asc
    #
    # @raise [ServerError] 服务端异常返回
    #
    # @return [Enumerator<Object>] 迭代器, 其中Object可能是COS::COSFile或COS::COSDir
    #
    # @example
    #  all = bucket.list
    #  all.each do |o|
    #    if o.is_a?(COS::COSFile)
    #      puts "File: #{o.name} #{o.format_size}"
    #    else
    #      puts "Dir: #{o.name} #{o.created_at}"
    #    end
    #  end
    def list(path = '', options = {})
      Resource.new(self, path, options).to_enum
    end

    alias :ls :list

    # 上传文件, 大文件自动断点续传, 多线程上传
    #
    # @param path_or_dir [String|COS::COSDir] 目录路径或目录对象COSDir
    #  目录路径如: '/', 'path1', 'path1/path2', sdk会补齐末尾的 '/'
    # @param file_name [String] 文件名
    # @param file_src [String] 本地文件路径
    # @param options [Hash] 高级参数
    # @option options [Boolean] :auto_create_folder 自动创建远端目录
    # @option options [Integer] :min_slice_size 完整上传最小文件大小,
    #  超过此大小将会使用分片多线程断点续传
    # @option options [Integer] :upload_retry 上传重试次数, 默认10
    # @option options [String] :biz_attr 目录属性, 业务端维护
    # @option options [Boolean] :disable_cpt 是否禁用checkpoint功能，如
    #  果设置为true，则在上传的过程中不会写checkpoint文件，这意味着
    #  上传失败后不能断点续传，而只能重新上传整个文件。如果这个值为
    #  true，则:cpt_file会被忽略。
    # @option options [Integer] :threads 多线程上传线程数, 默认为10
    # @option options [Integer] :slice_size 设置分片上传时每个分片的大小
    #  默认为3 MB, 目前服务端最大限制也为3MB。
    # @option options [String] :cpt_file 断点续传的checkpoint文件，如果
    #  指定的cpt文件不存在，则会在file所在目录创建一个默认的cpt文件，
    #  命名方式为：file.cpt，其中file是用户要上传的文件名。在上传的过
    #  程中会不断更新此文件，成功完成上传后会删除此文件；如果指定的
    #  cpt文件已存在，则从cpt文件中记录的点继续上传。
    #
    # @yield [Float] 上传进度百分比回调, 进度值是一个0-1之间的小数
    #
    # @raise [ServerError] 服务端异常返回
    #
    # @return [COS::COSFile]
    #
    # @example
    #   file = bucket.upload('path', 'file1', '~/test/file1') do |p|
    #     puts "上传进度: #{(p*100).round(2)}%")
    #   end
    #   puts file.url
    def upload(path_or_dir, file_name, file_src, options = {}, &block)
      dir = get_dir(path_or_dir, options[:auto_create_folder])

      min_size    = options[:min_slice_size] || MIN_UPLOAD_SLICE_SIZE
      retry_times = options[:upload_retry] || DEFAULT_UPLOAD_RETRY

      options.merge!({bucket: bucket_name})
      file_src  = File.expand_path(file_src)
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

    # 批量上传目录下的全部文件(不包含子目录)
    #
    # @note 已存在的文件不会再次上传, 本地目录中的隐藏文件(已"."开头的)不会上传
    #  ".cpt"文件不会上传, 不会上传子目录
    #
    # @param path_or_dir [String|COS::COSDir] 目录路径或目录对象COSDir
    #  目录路径如: '/', 'path1', 'path1/path2', sdk会补齐末尾的 '/'
    # @param file_src_path [String] 本地文件夹路径
    # @param options [Hash] 高级参数
    # @option options [Boolean] :auto_create_folder 自动创建远端目录
    # @option options [Integer] :min_slice_size 完整上传最小文件大小,
    #  超过此大小将会使用分片多线程断点续传
    # @option options [Integer] :upload_retry 上传重试次数, 默认10
    # @option options [String] :biz_attr 目录属性, 业务端维护
    # @option options [Boolean] :disable_cpt 是否禁用checkpoint功能，如
    #  果设置为true，则在上传的过程中不会写checkpoint文件，这意味着
    #  上传失败后不能断点续传，而只能重新上传整个文件。如果这个值为
    #  true，则:cpt_file会被忽略。
    # @option options [Integer] :threads 多线程上传线程数, 默认为10
    # @option options [Integer] :slice_size 设置分片上传时每个分片的大小
    #  默认为3 MB, 目前服务端最大限制也为3MB。
    # @option options [String] :cpt_file 断点续传的checkpoint文件，如果
    #  指定的cpt文件不存在，则会在file所在目录创建一个默认的cpt文件，
    #  命名方式为：file.cpt，其中file是用户要上传的文件名。在上传的过
    #  程中会不断更新此文件，成功完成上传后会删除此文件；如果指定的
    #  cpt文件已存在，则从cpt文件中记录的点继续上传。
    #
    # @yield [Float] 上传进度百分比回调, 进度值是一个0-1之间的小数
    #
    # @raise [ServerError] 服务端异常返回
    #
    # @return [Array<COS::COSFile>]
    #
    # @example
    #   files = bucket.upload_all('path', '~/test') do |p|
    #     puts "上传进度: #{(p*100).round(2)}%")
    #   end
    #   files.each do |file|
    #     puts file.url
    #   end
    def upload_all(path_or_dir, file_src_path, options = {}, &block)
      local_path = Util.get_local_path(file_src_path, false)
      uploaded   = []

      Dir.foreach(local_path) do |file|

        if !file.start_with?('.') and !file.end_with?('.cpt') and !File.directory?(file)
          logger.info("Begin to upload file >> #{file}")

          begin
            # 逐个上传
            uploaded << upload(path_or_dir, file, "#{local_path}/#{file}", options, &block)
          rescue => error
            # 跳过错误
            if options[:skip_error]
              logger.info("#{file} error skipped")
              next
            else
              # 终止上传抛出异常
              raise error
            end
          end

          logger.info("#{file} upload finished")
        end

      end

      uploaded
    end

    # 获取文件或目录信息
    #
    # @note 如查询根目录('/', '')可以获取到bucket信息, 返回COSDir
    #
    # @param path [String] 资源路径, 如: 目录'path1/', 文件'path1/file'
    #
    # @raise [ServerError] 服务端异常返回
    #
    # @return [COSFile|COSDir] 如果是目录则返回COSDir资源对象,是文件则返回COSFile资源对象
    #
    # @example
    #   puts bucket.stat('path1/file').name
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
    #
    # @param path [String] 资源路径, 如: 目录'path1/', 文件'path1/file'
    # @param biz_attr [String] 目录/文件属性，业务端维护
    #
    # @raise [ServerError] 服务端异常返回
    #
    # @example
    #   bucket.update('path1/file', 'i am the attr')
    def update(path, biz_attr)
      client.api.update(path, biz_attr, bucket: bucket_name)
    end

    # 删除文件或目录
    #
    # @note 非空目录及根目录不可删除,会抛出异常
    #
    # @param path [String] 资源路径, 如: 目录'path1/', 文件'path1/file'
    #
    # @raise [ServerError] 服务端异常返回
    #
    # @example
    #   bucket.delete('path1/file')
    def delete(path)
      client.api.delete(path, bucket: bucket_name)
    end

    # 删除文件或目录, 不会抛出异常而是返回布尔值
    #
    # @note 非空目录及根目录不可删除, 返回false
    #
    # @param path [String] 资源路径, 如: 目录'path1/', 文件'path1/file'
    #
    # @example
    #   puts bucket.delete!('path1/file')
    def delete!(path)
      delete(path)
      true
    rescue
      false
    end

    # 目录是否是空的
    #
    # @param path [String] 资源路径, 如: 目录'path1/', 文件'path1/file'
    #
    # @raise [ServerError] 服务端异常返回
    #
    # @return [Boolean] 是否为空
    #
    # @example
    #   puts bucket.empty?('path1/')
    def empty?(path = '')
      count(path) == 0
    end

    # 文件或目录是否存在
    #
    # @param path [String] 资源路径, 如: 目录'path1/', 文件'path1/file'
    #
    # @raise [ServerError] 服务端异常返回
    #
    # @return [Boolean] 是否存在
    #
    # @example
    #   puts bucket.exist?('path1/file1')
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
    #
    # @param path [String] 文件资源路径, 如: 'path1/file'
    #
    # @raise [ServerError] 服务端异常返回
    #
    # @return [Boolean] 是否完成
    #
    # @example
    #   puts bucket.complete?('path1/file1')
    def complete?(path)
      get_file(path).complete?
    end

    # 获取文件可访问的URL
    #
    # @note 私有读取的bucket会自动生成带签名的URL
    #
    # @param path_or_file [String] 文件资源COSFile或路径, 如: 'path1/file'
    # @param options [Hash] 高级参数
    # @option options [String] :cname 在cos控制台设置的cname域名
    # @option options [Boolean] :https 是否生成https的URL
    # @option options [Integer] :expire_seconds 签名有效时间(秒,私有读取bucket时需要)
    #
    # @raise [ServerError] 服务端异常返回
    #
    # @return [String] 文件访问URL
    #
    # @example
    #   puts bucket.url('path1/file1', https: true, cname: 'static.domain.com')
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
        sign = client.signature.multiple(
            bucket_name,
            options[:expire_seconds] || client.config.multiple_sign_expire)

        "#{url}?sign=#{sign}"
      else
        url
      end
    end

    # 下载文件, 支持断点续传, 支持多线程
    #
    # @param path_or_file [String|COS::COSFile] 文件路径或文件对象COSFile
    # @param file_store [String] 本地文件存储路径
    # @param options [Hash] 高级参数
    # @option options [Integer] :min_slice_size 完整下载最小文件大小,
    #  超过此大小将会使用分片多线程断点续传
    # @option options [Integer] :download_retry 下载重试次数, 默认10
    # @option options [Boolean] :disable_cpt 是否禁用checkpoint功能，如
    #  果设置为true，则在下载的过程中不会写checkpoint文件，这意味着
    #  下载失败后不能断点续传，而只能重新下载整个文件。如果这个值为
    #  true，则:cpt_file会被忽略。
    # @option options [Integer] :threads 多线程下载线程数, 默认为10
    # @option options [Integer] :slice_size 设置分片下载时每个分片的大小
    #  默认为5 MB。
    # @option options [String] :cpt_file 断点续传的checkpoint文件，如果
    #  指定的cpt文件不存在，则会在file所在目录创建一个默认的cpt文件，
    #  命名方式为：file.cpt，其中file是用户要下载的文件名。在下载的过
    #  程中会不断更新此文件，成功完成下载后会删除此文件；如果指定的
    #  cpt文件已存在，则从cpt文件中记录的点继续下载。
    #
    # @yield [Float] 下载进度百分比回调, 进度值是一个0-1之间的小数
    #
    # @raise [ServerError] 服务端异常返回
    #
    # @return [String]
    #
    # @example
    #   file = bucket.download('path/file1', '~/test/file1') do |p|
    #     puts "下载进度: #{(p*100).round(2)}%")
    #   end
    #   puts file
    def download(path_or_file, file_store, options = {}, &block)
      min_size    = options[:min_slice_size] || MIN_DOWNLOAD_SLICE_SIZE
      retry_times = options[:download_retry] || DEFAULT_DOWNLOAD_RETRY

      # 如果传入的是一个路径需要先获取文件信息
      file = get_file(path_or_file)

      # 检查文件是否上传完整才能下载
      unless file.complete?
        raise FileUploadNotComplete, 'file upload not complete'
      end

      # 检查本地文件sha1是否一致, 如一致就已下载完成了
      if file.sha1_match?(file_store)
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

    # 批量下载目录下的全部文件(不包含子目录)
    #
    # @note sdk会自动创建本地目录
    #
    # @param path_or_dir [String|COS::COSDir] 目录路径或目录对象COSDir
    #  目录路径如: '/', 'path1', 'path1/path2', sdk会补齐末尾的 '/'
    # @param file_store_path [String] 本地文件存储目录
    # @param options [Hash] 高级参数
    # @option options [Integer] :min_slice_size 完整下载最小文件大小,
    #  超过此大小将会使用分片多线程断点续传
    # @option options [Integer] :disable_mkdir 禁止自动创建本地文件夹, 默认会创建
    # @option options [Integer] :download_retry 下载重试次数, 默认10
    # @option options [Boolean] :disable_cpt 是否禁用checkpoint功能，如
    #  果设置为true，则在下载的过程中不会写checkpoint文件，这意味着
    #  下载失败后不能断点续传，而只能重新下载整个文件。如果这个值为
    #  true，则:cpt_file会被忽略。
    # @option options [Integer] :threads 多线程下载线程数, 默认为10
    # @option options [Integer] :slice_size 设置分片下载时每个分片的大小
    #  默认为5 MB。
    # @option options [String] :cpt_file 断点续传的checkpoint文件，如果
    #  指定的cpt文件不存在，则会在file所在目录创建一个默认的cpt文件，
    #  命名方式为：file.cpt，其中file是用户要下载的文件名。在下载的过
    #  程中会不断更新此文件，成功完成下载后会删除此文件；如果指定的
    #  cpt文件已存在，则从cpt文件中记录的点继续下载。
    #
    # @yield [Float] 下载进度百分比回调, 进度值是一个0-1之间的小数
    #
    # @raise [ServerError] 服务端异常返回
    #
    # @return [Array<String>] 本地文件路径数组
    #
    # @example
    #   files = bucket.download_all('path/', '~/test/') do |p|
    #     puts "下载进度: #{(p*100).round(2)}%")
    #   end
    #   puts files
    def download_all(path_or_dir, file_store_path, options = {}, &block)
      local_path = Util.get_local_path(file_store_path, options[:disable_mkdir])
      dir        = get_dir(path_or_dir)
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
    #
    # @param path_or_dir [String|COS::COSDir] 目录路径或目录对象COSDir
    #  目录路径如: '/', 'path1', 'path1/path2', sdk会补齐末尾的 '/'
    # @param options [Hash]
    # @option options [Integer] :depth 子目录深度,默认为5
    #
    # @raise [ServerError] 服务端异常返回
    #
    # @return [Hash]
    #
    # @example
    #  tree = bucket.tree
    #  puts tree[:resource].name
    #  tree[:children].each do |r|
    #    puts r[:resource].name
    #  end
    #
    # {
    #   :resource => resource,
    #   :children => [
    #     {:resource => resource, :children => [...]},
    #     {:resource => resource, :children => [...]},
    #     ...
    #   ]
    # }
    def tree(path_or_dir = '', options = {})
      dir = get_dir(path_or_dir)
      Tree.new(options.merge({path: dir})).to_object
    end

    # 获取Hash格式的目录树形结构, 可用于直接to_json
    #
    # @param path_or_dir [String|COS::COSDir] 目录路径或目录对象COSDir
    #  目录路径如: '/', 'path1', 'path1/path2', sdk会补齐末尾的 '/'
    # @param options [Hash]
    # @option options [Integer] :depth 子目录深度,默认为5
    #
    # @raise [ServerError] 服务端异常返回
    #
    # @return [Hash<Object>]
    #
    # @example
    #  puts bucket.hash_tree.to_json
    #
    # {
    #   :resource => {name: '', mtime: ''...},
    #   :children => [
    #     {:resource => resource, :children => [...]},
    #     {:resource => resource, :children => [...]},
    #     ...
    #   ]
    # }
    def hash_tree(path_or_dir = '', options = {})
      dir = get_dir(path_or_dir)
      Tree.new(options.merge({path: dir})).to_hash
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

        dir = handle_folder(path_or_dir, auto_create_folder)
        get_dir(dir)

      else
        raise ClientError,
              "can't get dir from #{path_or_dir.class}, " \
              'must be a file path string or COS::COSDir'

      end
    end

    # 获取目录信息并可以自动创建目录
    def handle_folder(path_or_dir, auto_create_folder = false)
      return stat(path_or_dir)
    rescue => error
      unless auto_create_folder
        raise error
      end

      # 自动创建目录
      if error.is_a?(COS::ServerError) and error.error_code == -166
        logger.info('path not exist, auto create folder...')
        return create_folder(path_or_dir)
      end

      raise error
    end

  end

end