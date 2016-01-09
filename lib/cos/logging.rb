# coding: utf-8

require 'logger'

module COS

  module Logging

    DEFAULT_LOG_FILE = './cos-sdk.log'
    MAX_NUM_LOG = 100
    ROTATE_SIZE = 10 * 1024 * 1024

    # level = Logger::DEBUG | Logger::INFO | Logger::ERROR | Logger::FATAL

    # 设置日志输出的文件
    def self.set_logger(file, level)
      if file == STDOUT or file == STDERR
        @logger = Logger.new(file)
        @logger.level = level
      else
        @logger = Logger.new(file, MAX_NUM_LOG, ROTATE_SIZE)
        @logger.level = level
      end
    end

    # 获取logger
    def logger
      Logging.logger
    end

    private

    def self.logger
      unless @logger
        @logger = Logger.new(
            @log_file ||= DEFAULT_LOG_FILE, MAX_NUM_LOG, ROTATE_SIZE)
        @logger.level = Logger::INFO
      end

      @logger
    end

  end

end