# coding: utf-8

require 'digest'
require 'fileutils'

module COS
  module Util

    class << self

      # 文件sha1
      def file_sha1(file)
        Digest::SHA1.file(file).hexdigest
      end

      # 字符串sha1
      def string_sha1(string)
        Digest::SHA1.hexdigest(string)
      end

      # 获取本地目录路径, 不存在会创建
      def get_local_path(path, disable_mkdir = false)
        local = File.expand_path(path)
        unless File.exist?(local) and File.directory?(local)
          # 创建目录
          if disable_mkdir
            raise LocalPathNotExist, "Local path #{local} not exist!"
          else
            FileUtils::mkdir_p(local)
          end
        end

        local
      end

      # 解析list时的path
      def get_list_path(path, name = '', is_file = false)
        # 目录必须带"/"
        path = "/#{path}" unless path.start_with?('/')

        if is_file
          # 文件
          if path.end_with?('/')
            "#{path}#{name}"
          else
            "#{path}/#{name}"
          end
        else
          # 目录
          if path.end_with?('/')
            "#{path}#{name}/"
          else
            "#{path}/#{name}/"
          end
        end
      end

      # 获取resource_path
      def get_resource_path(app_id, bucket, path, file = nil)
        # file_name检测
        if file and (file.end_with?('/') or file.start_with?('/'))
          raise ClientError, "File name can't start or end with '/'"
        end

        # 目录必须带"/"
        path = "/#{path}" unless path.start_with?('/')
        path = "#{path}/" unless path.end_with?('/')

        "/#{app_id}/#{bucket}#{path}#{file}"
      end

      # 获取resource_path, 不自动添加'/'
      def get_resource_path_or_file(app_id, bucket, path)
        # 目录必须带"/"
        path = "/#{path}" unless path.start_with?('/')
        "/#{app_id}/#{bucket}#{path}"
      end

    end

  end
end