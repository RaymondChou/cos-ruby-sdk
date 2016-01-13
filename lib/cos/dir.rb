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
    def upload(file_name, file_src, options = {}, &block)
      bucket.upload(path, file_name, file_src, options, &block)
    end

    # 上传本地目录中的所有文件至此目录
    def upload_all

    end

    # 下载当前目录中的所有文件(不含子目录)
    def download_all

    end

    # 列出目录
    def list(options = {})
      bucket.list(path, options)
    end

    alias :ls :list

    # 获取目录树形结构
    def tree(options = {})
      bucket.tree(path, options)
    end

    # 创建目录
    def create_folder(dir_name, options = {})
      bucket.create_folder("#{path}#{dir_name}", options)
    end

    alias :mkdir :create_folder

    # 获取文件或目录总数信息
    def list_count(options = {})
      bucket.list_count(path, options)
    end

    # 获取文件及目录总数
    def count
      bucket.count(path)
    end

    alias :size :count

    # 获取文件数
    def count_files
      bucket.count_files(path)
    end

    # 获取目录数
    def count_dirs
      bucket.count_dirs(path)
    end

    # 目录是否是空的
    def empty?
      bucket.empty?(path) == 0
    end

  end

end