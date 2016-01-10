# coding: utf-8

require 'rest-client'
require 'uri'

module COS

  class HTTP

    # 默认content-type
    DEFAULT_CONTENT_TYPE = 'application/json'

    # 请求创建超时
    OPEN_TIMEOUT = 15

    # 响应读取超时
    READ_TIMEOUT = 120

    include Logging

    attr_reader :config, :signature

    def initialize(config)
      @config    = config
      @signature = Signature.new(config)
    end

    # GET请求
    def get(path, headers, signature = nil)
      do_request('GET', path, headers, signature)
    end

    # POST请求
    def post(path, headers, signature, payload)
      do_request('POST', path, headers, signature, payload)
    end

    private

    # 发送请求
    def do_request(method, path, headers, signature = nil, payload = nil)

      # 整理头部信息
      headers['content-type']  ||= DEFAULT_CONTENT_TYPE
      headers['user-agent']    = get_user_agent
      headers['authorization'] = signature
      headers['accept'] = 'application/json'

      # 请求地址
      url = "#{config.api_base}#{path}"

      logger.debug("Send HTTP request, method: #{method}, url: " \
                      "#{url}, headers: #{headers}, payload: #{payload}")

      response = RestClient::Request.execute(
          :method       => method,
          :url          => URI.encode(url),
          :headers      => headers,
          :payload      => payload,
          :open_timeout => @config.open_timeout || OPEN_TIMEOUT,
          :timeout      => @config.read_timeout || READ_TIMEOUT
      ) do |resp, request, result, &blk|

        # 捕获异常
        if resp.code >= 300
          e = ServerError.new(resp)
          logger.warn(e.to_s)
          raise e
        else
          resp.return!(request, result, &blk)
        end

      end

      logger.debug("Received HTTP response, code: #{response.code}, headers: " \
                      "#{response.headers}, body: #{response.body}")

      # 解析JSON结果
      parse_data(response)
    end

    # 解析结果json 取出data部分
    def parse_data(response)
      j = JSON.parse(response.body, symbolize_names: true)
      j[:data]
    end

    # 获取user agent
    def get_user_agent
      "cos-ruby-sdk/#{VERSION} ruby-#{RUBY_VERSION}/#{RUBY_PLATFORM}"
    end

  end

end