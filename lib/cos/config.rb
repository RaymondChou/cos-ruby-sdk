module COS

  class Config < Struct::Base

    DEFAULT_HOST = 'web.file.myqcloud.com'
    DEFAULT_MULTIPLE_SIGN_EXPIRE = 600

    required_attrs :app_id, :secret_id, :secret_id, :secret_key
    optional_attrs :host, :protocol, :open_timeout, :read_timeout, :logger, :multiple_sign_expire, :bucket

    attr_reader :api_base

    def initialize(options = {})
      super(options)

      Logging.set_logger(STDOUT, Logger::DEBUG)

      @protocol ||= 'http'
      @host     ||= DEFAULT_HOST
      @api_base = "#{@protocol}://#{@host}/files/v1"
      @multiple_sign_expire ||= DEFAULT_MULTIPLE_SIGN_EXPIRE
    end

    # 自定义bucket或从config中获取
    def get_bucket(custom_bucket)
      b = custom_bucket || bucket
      if b == nil
        raise ClientError, 'Bucket must defined in Config or api options'
      end
      b
    end

  end

end