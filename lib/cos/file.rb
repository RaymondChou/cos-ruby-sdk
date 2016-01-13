# coding: utf-8

module COS

  # COS文件资源
  class COSFile < ResourceOperator

    STORAGE_UNITS = %w[B KB MB GB]
    STORAGE_BASE = 1024

    # 初始化
    #
    # @param [Hash] attrs 参数
    # @option attrs [Bucket] :bucket COS::Bucket对象
    # @option attrs [String] :path 存储路径
    # @option attrs [String] :name 文件名
    # @option attrs [String] :ctime 创建时间unix时间戳
    # @option attrs [String] :mtime 修改时间unix时间戳
    # @option attrs [String] :biz_attr 业务信息
    # @option attrs [String] :filesize 文件存储大小
    # @option attrs [String] :filelen 文件大小
    # @option attrs [String] :sha 文件sha1值
    # @option attrs [String] :access_url 文件访问地址
    #
    # @raise [AttrError] 缺少参数
    #
    # @return [COS::COSFile]
    def initialize(attrs = {})
      super(attrs)
      @type = 'file'
    end

    # 获取文件存储大小并转为数值型
    #
    # @return [Integer] 文件存储大小
    def filesize
      @filesize.to_i
    end

    # 获取文件大小并转为数值型
    #
    # @return [Integer] 文件大小
    def filelen
      @filelen.to_i
    end

    # 判断文件sha1是否一致
    #
    # @return [Boolean] 是否一致
    def sha1_match?(file)
      File.exist?(file) and sha.upcase == Util.file_sha1(file).upcase
    end

    # 文件大小
    #
    # @alias filesize
    def size
      filesize.to_i
    end

    # 获取格式化的文件大小
    #
    # @example
    #  1B 1KB 1.1MB 1.12GB...
    #
    # @return [String]
    def format_size
      if filesize.to_i < STORAGE_BASE
        size_str = filesize.to_s + STORAGE_UNITS[0]
      else
        c_size = human_rep(filesize.to_i)
        size_str = "%.2f" % c_size[:size].round(2)
        size_str = "#{size_str}#{c_size[:unit]}"
      end

      size_str
    end

    # 文件是否完整, 是否上传完了
    #
    # @return [Boolean] 是否完整
    def complete?
      access_url != nil and filelen == filesize
    end

    # 获取文件的URL, 支持cname, https
    #
    # @note 私有读取的bucket会自动生成带签名的URL
    #
    # @param options [Hash] 高级参数
    # @option options [String] :cname 在cos控制台设置的cname域名
    # @option options [Boolean] :https 是否生成https的URL
    # @option options [Integer] :expire_seconds 签名有效时间(秒,私有读取bucket时需要)
    #
    # @raise [ServerError] 服务端异常返回
    #
    # @return [String] 文件访问URL
    def url(options = {})
      bucket.url(self, options)
    end

    # 下载当前文件, 支持断点续传, 支持多线程
    #
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
    # @see Bucket#download
    def download(file_store, options = {}, &block)
      bucket.download(self, file_store, options, &block)
    end

    private

    # 计算文件大小格式化单位
    def human_rep(bytes)
      number   = Float(bytes)
      max_exp  = STORAGE_UNITS.size - 1

      exponent = (Math.log(bytes) / Math.log(STORAGE_BASE)).to_i
      exponent = max_exp if exponent > max_exp

      number   /= STORAGE_BASE ** exponent
      unit     = STORAGE_UNITS[exponent]

      { size: number, unit: unit }
    end

  end

end