require 'digest'

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

      # 获取resource_path
      def get_resource_path(app_id, bucket, path, file = nil)
        # file_name检测
        if file and file.end_with?('/')
          raise ClientError, "File name can't end with '/'"
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