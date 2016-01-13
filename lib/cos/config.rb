# coding: utf-8

require 'yaml'

module COS

  class Config < Struct::Base

    # 默认服务HOST
    DEFAULT_HOST = 'web.file.myqcloud.com'

    # 默认多次签名过期时间(单位秒)
    DEFAULT_MULTIPLE_SIGN_EXPIRE = 600

    # 必选参数 [Hash]
    required_attrs :app_id, :secret_id, :secret_key

    # 可选参数 [Hash]
    optional_attrs :host, :protocol, :open_timeout, :read_timeout, :config,
                   :log_src, :log_level, :multiple_sign_expire, :default_bucket

    attr_reader :api_base

    # 初始化
    #
    # @example
    #   COS::Config.new(app_id: '', secret_id: '', secret_key: '')
    #
    # @param options [Hash] 客户端配置
    # @option options [String] :app_id COS分配的app_id
    # @option options [String] :secret_id COS分配的secret_id
    # @option options [String] :secret_key COS分配的secret_key
    # @option options [String] :host COS服务host地址
    # @option options [String] :protocol 使用协议,默认为http,可选https
    # @option options [Integer] :open_timeout 接口通讯建立连接超时秒数
    # @option options [Integer] :read_timeout 接口通讯读取数据超时秒数
    # @option options [String] :config 配置文件路径
    # @option options [String|Object] :log_src 日志输出
    #  STDOUT | STDERR | 'path/filename.log'
    # @option options [Logger] :log_level 日志级别
    #  Logger::DEBUG | Logger::INFO | Logger::ERROR | Logger::FATAL
    # @option options [String] :multiple_sign_expire 多次签名过期时间(单位秒)
    # @option options [String] :default_bucket 默认bucket
    #
    # @return [COS::Config]
    #
    # @raise [AttrError] 如果缺少参数会抛出参数错误异常
    def initialize(options = {})
      # 从配置文件加载配置
      if options[:config]
        config = load_config_file(options[:config])
        options.merge!(config)
      end

      super(options)

      # log_src: STDOUT | STDERR | 'path/filename.log'
      # log_level: Logger::DEBUG | Logger::INFO | Logger::ERROR | Logger::FATAL
      if options[:log_src]
        Logging.set_logger(
            options[:log_src],
            options[:log_level] || Logger::INFO
        )
      end

      @protocol ||= 'http'
      @host     ||= DEFAULT_HOST
      @api_base = "#{@protocol}://#{@host}/files/v1"
      @multiple_sign_expire ||= DEFAULT_MULTIPLE_SIGN_EXPIRE
    end

    # 获取指定的bucket或从config中获取默认bucket
    #
    # @params custom_bucket [String] bucket名称
    #
    # @return [String]
    #
    # @raise [ClientError]
    def get_bucket(custom_bucket)
      b = custom_bucket || default_bucket
      if b == nil
        raise ClientError, 'Bucket name must be set'
      end
      b
    end

    private

    # 加载yaml配置文件
    def load_config_file(config_file)
      hash = YAML.load(File.read(File.expand_path(config_file)))

      # Hash key字符串转为symbol
      hash.keys.each do |key|
        hash[(key.to_sym rescue key) || key] = hash.delete(key)
      end
      hash
    end

  end

end