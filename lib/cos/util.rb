require 'digest'

module COS
  module Util

    class << self

      def file_sha1(file)
        Digest::SHA1.file(file).hexdigest
      end

      def string_sha1(string)
        Digest::SHA1.hexdigest(string)
      end

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

    end

  end
end