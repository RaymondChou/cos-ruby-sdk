require 'digest'

module COS
  module Util

    class << self

      def file_sha1(file)
        Digest::SHA1.file(file).hexdigest
      end

    end

  end
end