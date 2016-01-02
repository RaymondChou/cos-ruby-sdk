require 'json'

module COS

  class API

    attr_reader :config, :http, :signature

    def initialize(config)
      @config    = config
      @http      = COS::HTTP.new(config)
      @signature = COS::Signature.new(config)
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
      sign    = signature.multiple(bucket)
      payload = {op: 'create', biz_attr: options[:biz_attr]}

      http.post(get_resource_path(bucket, path), {}, sign, payload.to_json)
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
      bucket        = config.get_bucket(options[:bucket])
      sign          = signature.multiple(bucket)
      resource_path = get_resource_path(bucket, path, file_name)

      payload = {
          op: 'upload',
          sha: Util.file_sha1(file_src),
          filecontent: File.new(file_src, 'rb'),
          biz_attr: options[:biz_attr]
      }

      http.post(resource_path, {}, sign, payload)
    end

    def upload_slice

    end

    def list

    end

    def update

    end

    def stat

    end

    def delete

    end

    private

    def get_resource_path(bucket, path, file = nil)
      # file_name检测
      if file and file.end_with?('/')
        raise ClientError, "File name can't end with '/'"
      end

      # 目录必须带"/"
      path = "/#{path}" unless path.start_with?('/')
      path = "#{path}/" unless path.end_with?('/')

      "/#{config.app_id}/#{bucket}#{path}#{file}"
    end

  end

end