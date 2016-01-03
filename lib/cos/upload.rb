require 'tempfile'

module COS

  class Upload

    attr_reader :http, :config

    def initialize(config, http)
      @config = config
      @http   = http
    end

    def entire_upload(path, file_name, file_src, options = {})
      bucket        = config.get_bucket(options[:bucket])
      sign          = http.signature.multiple(bucket)
      resource_path = Util.get_resource_path(config.app_id, bucket, path, file_name)

      payload = {
          op:            'upload',
          sha:           Util.file_sha1(file_src),
          filecontent:   File.new(file_src, 'rb'),
          biz_attr:      options[:biz_attr]
      }

      http.post(resource_path, {}, sign, payload)
    end

    def slice_upload_prepare(path, file_name, file_src, options = {})
      bucket        = config.get_bucket(options[:bucket])
      sign          = http.signature.multiple(bucket)
      resource_path = Util.get_resource_path(config.app_id, bucket, path, file_name)
      file_size     = File.size(file_src)

      payload = {
          op:          'upload_slice',
          sha:         Util.file_sha1(file_src),
          filesize:    file_size,
          biz_attr:    options[:biz_attr],
          session:     options[:session],
          multipart:   true
      }

      http.post(resource_path, {}, sign, payload).merge({file_size: file_size})
    end

    def slice_upload(path, file_name, file_src, options = {}, &block)
      bucket        = config.get_bucket(options[:bucket])
      sign          = http.signature.multiple(bucket)
      resource_path = Util.get_resource_path(config.app_id, bucket, path, file_name)
      temp_file     = Tempfile.new("#{options[:session]}-#{options[:offset]}")

      begin
        # 复制文件部分
        IO.copy_stream(file_src, temp_file, options[:slice_size], options[:offset])

        payload = {
            op:          'upload_slice',
            sha:         Util.file_sha1(temp_file),
            offset:      options[:offset],
            session:     options[:session],
            filecontent: temp_file,
            multipart:   true
        }

        http.post(resource_path, {}, sign, payload).merge({file_size: options[:file_size]})
      ensure
        temp_file.close
        temp_file.unlink
      end
    end

  end

end