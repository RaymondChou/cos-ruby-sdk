# coding: utf-8

module COS

  # COS目录资源
  class COSDir < ResourceOperator

    # 初始化
    #
    # @param [Hash] attrs 参数
    # @option attrs [Bucket] :bucket COS::Bucket对象
    # @option attrs [String] :path 存储路径
    # @option attrs [String] :name 文件名
    # @option attrs [String] :ctime 创建时间unix时间戳
    # @option attrs [String] :mtime 修改时间unix时间戳
    # @option attrs [String] :biz_attr 业务信息
    # @option attrs [String] :authority bucket权限(根目录bucket)
    # @option attrs [Integer] :bucket_type bucket类型(根目录bucket)
    # @option attrs [String] :migrate_source_domain 回源地址(根目录bucket)
    # @option attrs [String] :need_preview need_preview(根目录bucket)
    # @option attrs [Array<String>] :refers refers(根目录bucket)
    #
    # @raise [AttrError] 缺少参数
    #
    # @return [COS::COSDir]
    def initialize(attrs = {})
      super(attrs)
      @type = 'dir'
    end

    # 在当前目录中上传文件,自动判断使用分片上传,断点续传及自动重试,多线程上传
    #
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
    #   file = dir.upload('file1', '~/test/file1') do |p|
    #     puts "上传进度: #{(p*100).round(2)}%")
    #   end
    #   puts file.url
    def upload(file_name, file_src, options = {}, &block)
      bucket.upload(self, file_name, file_src, options, &block)
    end

    # 批量上传本地目录中的所有文件至此目录
    #
    # @note 已存在的文件不会再次上传, 本地目录中的隐藏文件(已"."开头的)不会上传
    #  ".cpt"文件不会上传, 不会上传子目录
    #
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
    #   files = dir.upload_all('~/test') do |p|
    #     puts "上传进度: #{(p*100).round(2)}%")
    #   end
    #   files.each do |file|
    #     puts file.url
    #   end
    def upload_all(file_src_path, options = {}, &block)
      bucket.upload_all(self, file_src_path, options, &block)
    end

    # 批量下载当前目录中的所有文件(不含子目录)
    #
    # @note sdk会自动创建本地目录
    #
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
    #   files = dir.download_all('~/test/') do |p|
    #     puts "下载进度: #{(p*100).round(2)}%")
    #   end
    #   puts files
    def download_all(file_store_path, options = {}, &block)
      bucket.download_all(self, file_store_path, options, &block)
    end

    # 列出当前文件夹下的目录及文件
    #
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
    #  all = dir.list
    #  all.each do |o|
    #    if o.is_a?(COS::COSFile)
    #      puts "File: #{o.name} #{o.format_size}"
    #    else
    #      puts "Dir: #{o.name} #{o.created_at}"
    #    end
    #  end
    def list(options = {})
      bucket.list(path, options)
    end

    alias :ls :list

    # 获取当前目录树形结构
    #
    # @param options [Hash]
    # @option options [Integer] :depth 子目录深度,默认为5
    #
    # @raise [ServerError] 服务端异常返回
    #
    # @return [Hash]
    #
    # @example
    #  tree = dir.tree
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
    def tree(options = {})
      bucket.tree(self, options)
    end

    # 获取当前目录Hash格式的目录树形结构, 可用于直接to_json
    #
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
    def hash_tree(options = {})
      bucket.hash_tree(self, options)
    end

    # 在当前目录下创建子目录
    #
    # @param options [Hash] 高级参数
    # @option options [String] :biz_attr 目录属性, 业务端维护
    #
    # @return [COS::COSDir]
    #
    # @raise [ServerError] 服务端异常返回
    def create_folder(dir_name, options = {})
      bucket.create_folder("#{path}#{dir_name}", options)
    end

    alias :mkdir :create_folder

    # 获取当前目录下得文件和子目录总数信息
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
    def list_count(options = {})
      bucket.list_count(path, options)
    end

    # 获取当前目录下的文件及子目录总数
    #
    # @return [Integer] 文件及子目录总数
    #
    # @raise [ServerError] 服务端异常返回
    def count
      bucket.count(path)
    end

    alias :size :count

    # 获取当前目录下的文件数
    #
    # @return [Integer] 文件数
    #
    # @raise [ServerError] 服务端异常返回
    def count_files
      bucket.count_files(path)
    end

    # 获取当前目录下的子目录数
    #
    # @return [Integer] 子目录数
    #
    # @raise [ServerError] 服务端异常返回
    def count_dirs
      bucket.count_dirs(path)
    end

    # 判断当前目录是否是空的
    #
    # @return [Boolean] 是否为空
    #
    # @raise [ServerError] 服务端异常返回
    def empty?
      bucket.empty?(path) == 0
    end

  end

end