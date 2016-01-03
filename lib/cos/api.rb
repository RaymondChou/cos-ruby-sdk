require 'json'

module COS

  class API

    attr_reader :config, :http

    def initialize(config)
      @config    = config
      @http      = COS::HTTP.new(config)
    end

    # 创建目录
    # @param path [String] 目录路径,
    #  如: 'path1', 'path1/path2', sdk会补齐末尾的 '/'
    # @param options [Hash] 高级参数
    # @option options [String] :biz_attr 目录属性, 业务端维护
    # @option options [String] :bucket bucket名称
    # @return Hash
    #  * :ctime [String] 创建时间Unix时间戳
    #  * :resource_path [String] 创建的资源路径
    def create_folder(path, options = {})
      bucket  = config.get_bucket(options[:bucket])
      sign    = http.signature.multiple(bucket)
      payload = {op: 'create', biz_attr: options[:biz_attr]}
      resource_path = Util.get_resource_path(config.app_id, bucket, path)

      http.post(resource_path, {}, sign, payload.to_json)
    end

    # 上传文件(完整上传)
    # @param path [String] 目录路径,
    #  如: '/', 'path1', 'path1/path2', sdk会补齐末尾的 '/'
    # @param file_name [String] 文件名
    # @param file_src [String] 本地文件路径
    # @param options [Hash] 高级参数
    # @option options [String] :biz_attr 目录属性, 业务端维护
    # @option options [String] :bucket bucket名称
    # @return Hash
    #  * :access_url [String] 生成的文件下载url
    #  * :url [String] 操作文件的url
    #  * :resource_path [String] 资源路径
    def upload(path, file_name, file_src, options = {})
      u = Upload.new(config, http)
      u.entire_upload(path, file_name, file_src, options)
    end

    # 上传文件(分片上传)
    # @param path [String] 目录路径,
    #  如: '/', 'path1', 'path1/path2', sdk会补齐末尾的 '/'
    # @param file_name [String] 文件名
    # @param file_src [String] 本地文件路径
    # @param options [Hash] 高级参数
    # @option options [String] :biz_attr 目录属性, 业务端维护
    # @option options [String] :bucket bucket名称
    # @yield [Float] 上传进度百分比回调, 进度值是一个0-1之间的小数
    # @return Hash
    #  * :access_url [String] 生成的文件下载url
    #  * :url [String] 操作文件的url
    #  * :resource_path [String] 资源路径
    def upload_slice(path, file_name, file_src, options = {}, &block)
      u = Upload.new(config, http)
      # 准备上传
      slice = u.slice_upload_prepare(path, file_name, file_src, options)
      options.merge!(slice)

      # 上一次已传完/秒传成功
      if slice[:access_url] != nil
        # 百分比直接完成
        block.call(1.to_f) if block
        return slice
      end

      # 百分比初始
      block.call(0.to_f) if block

      # 开始分片上传文件
      while options[:file_size] > options[:offset]
        slice = u.slice_upload(path, file_name, file_src, options, &block)
        options.merge!(slice)

        # 下一分片偏移
        options[:offset] += options[:slice_size]

        # 百分比回调
        block.call(options[:offset].to_f / options[:file_size].to_f) if block
      end

      {access_url: slice[:access_url], url: slice[:url], resource_path: slice[:resource_path]}
    end

    def list

    end

    def update

    end

    def stat

    end

    def delete

    end

  end

end