module COS

  class Config < Struct::Base

    DEFAULT_HOST = 'web.file.myqcloud.com'
    DEFAULT_MULTIPLE_SIGN_EXPIRE = 600

    required_attrs :app_id, :secret_id, :secret_key
    optional_attrs :host, :protocol, :open_timeout, :read_timeout,
                   :log_src, :log_level, :multiple_sign_expire, :default_bucket

    attr_reader :api_base

    def initialize(options = {})
      super(options)

      # log_src: STDOUT | STDERR | 'path/filename.log'
      # log_level: Logger::DEBUG | Logger::INFO | Logger::ERROR | Logger::FATAL
      Logging.set_logger(
          options[:log_src]   || STDOUT,
          options[:log_level] || Logger::INFO
      )

      @protocol ||= 'http'
      @host     ||= DEFAULT_HOST
      @api_base = "#{@protocol}://#{@host}/files/v1"
      @multiple_sign_expire ||= DEFAULT_MULTIPLE_SIGN_EXPIRE
    end

    # 自定义bucket或从config中获取
    def get_bucket(custom_bucket)
      b = custom_bucket || default_bucket
      if b == nil
        raise ClientError, 'Bucket name must be set'
      end
      b
    end

  end

end