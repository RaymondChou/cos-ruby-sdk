# coding: utf-8

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

end