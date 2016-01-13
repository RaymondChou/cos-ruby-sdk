# coding: utf-8

module COS

  class Client

    attr_reader :config, :api

    # 初始化
    #
    # @see COS::Config
    #
    # # @example
    #   COS::Client.new(app_id: '', secret_id: '', secret_key: '')
    #
    # @param options [Hash] 客户端配置
    #
    # @return [COS::Client]
    #
    # @raise [AttrError] 如果缺少参数会抛出参数错误异常
    def initialize(options = {})
      @config = Config.new(options)
      @api    = API.new(@config)
      @cache_buckets = {}
    end

    # 获取鉴权签名方法
    #
    # @see COS::Signature
    #
    # @return [COS::Signature]
    def signature
      api.http.signature
    end

    # 指定bucket 初始化Bucket类
    #
    # @note SDK会自动获取bucket的信息,包括读取权限等并进行缓存
    #  如需在后台修改了bucket信息请重新初始化Client
    #
    # @params bucket_name [String] bucket名称
    #  如果在初始化时的配置中设置了default_bucket则该字段可以为空,会获取默认的bucket
    #
    # @return [COS::Bucket]
    #
    # @raise [ServerError]
    def bucket(bucket_name = nil)
      unless @cache_buckets[bucket_name]
        # 缓存bucket对象
        @cache_buckets[bucket_name] = Bucket.new(self, bucket_name)
      end
      @cache_buckets[bucket_name]
    end

  end

end