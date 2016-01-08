require_relative 'cos/version'
require_relative 'cos/util'
require_relative 'cos/struct'
require_relative 'cos/logging'
require_relative 'cos/exception'
require_relative 'cos/config'
require_relative 'cos/signature'
require_relative 'cos/client'
require_relative 'cos/http'
require_relative 'cos/checkpoint'
require_relative 'cos/slice'
require_relative 'cos/api'
require_relative 'cos/resource'
require_relative 'cos/download'
require_relative 'cos/tree'

def self.client(options = {})
  unless @client

    # Rails配置
    if defined? Rails
      COS::Logging.set_logger(Rails.root.join('log/cos-sdk.log'), Logger::INFO)
      configs = options.merge(config: Rails.root.join('config/cos.yml'))
      @client = COS::Client.new(configs)
    else
      @client = COS::Client.new(options)
    end

  end

  @client
end