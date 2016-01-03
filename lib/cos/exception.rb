require 'json'

module COS

  # 异常基类
  class Exception < RuntimeError; end

  class ServerError < Exception

    attr_reader :response, :http_code, :error_code, :message

    def initialize(response)
      @response = response
      resp_obj  = JSON.parse(response.body)

      @error_code = resp_obj['code']
      @message    = resp_obj['message']
      @http_code  = response.code
    end

    def message
      @message || "UnknownError[#{http_code}]."
    end

    def to_s
      "ServerError Code: #{error_code}, Message: #{message}, HttpCode: #{http_code}"
    end

  end

  # 参数错误
  class AttrError < Exception; end

  # 客户端错误
  class ClientError < Exception; end

  # 文件不一致
  class FileInconsistentError < Exception; end

  # 上传进度记录损坏
  class CheckpointBrokenError < Exception; end

end