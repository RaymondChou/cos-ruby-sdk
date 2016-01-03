require 'rest-client'
require 'uri'

module COS

  class HTTP

    DEFAULT_CONTENT_TYPE = 'application/json'
    OPEN_TIMEOUT = 10
    READ_TIMEOUT = 120

    include Logging

    attr_reader :config, :signature

    def initialize(config)
      @config    = config
      @signature = Signature.new(config)
    end

    def get(path, headers, signature)
      do_request('GET', path, headers, signature)
    end

    def post(path, headers, signature, payload)
      do_request('POST', path, headers, signature, payload)
    end

    private

    def do_request(method, path, headers, signature = nil, payload = nil)

      headers['content-type']  ||= DEFAULT_CONTENT_TYPE
      headers['user-agent']    = get_user_agent
      headers['authorization'] = signature

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
      ) do |response, request, result, &blk|

        if response.code >= 300
          e = ServerError.new(response)
          logger.error(e.to_s)
          raise e
        else
          response.return!(request, result, &blk)
        end

      end

      logger.debug("Received HTTP response, code: #{response.code}, headers: " \
                      "#{response.headers}, body: #{response.body}")

      parse_data(response)
    end

    def parse_data(response)
      j = JSON.parse(response.body, symbolize_names: true)
      j[:data]
    end

    def get_user_agent
      "cos-ruby-sdk/#{VERSION} ruby-#{RUBY_VERSION}/#{RUBY_PLATFORM}"
    end

  end

end