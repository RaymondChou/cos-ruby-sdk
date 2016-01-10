# coding: utf-8

require 'json'

module COS

  # 异常基类
  class Exception < RuntimeError; end

  # 服务端返回异常
  # Code: -166, Message: 索引不存在, HttpCode: 400
  # Code: -173, Message: 目录非空, HttpCode: 400
  # Code: -180, Message: 非法路径, HttpCode: 400
  # Code: -288, Message: process打包失败, HttpCode: 400
  # Code: -4018, Message: 相同文件已上传过, HttpCode: 400
  # Code: -5997, Message: 后端网络错误, HttpCode: 400
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

  # 断点续传记录损坏
  class CheckpointBrokenError < Exception; end

  # 下载错误
  class DownloadError < Exception; end

  # 文件上传未完成
  class FileUploadNotComplete < Exception; end

end