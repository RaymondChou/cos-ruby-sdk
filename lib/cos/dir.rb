# coding: utf-8

module COS

  # COS目录资源
  class COSDir < ResourceOperator

    def initialize(attrs = {})
      super(attrs)
      @type = 'dir'
    end

    # 上传文件,自动判断使用分片上传,断点续传及自动重试,多线程上传
    def upload(file_name, file_src, options = {}, &block)
      bucket.upload(path, file_name, file_src, options, &block)
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