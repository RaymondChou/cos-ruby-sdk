module COS

  class Client

    attr_reader :config, :api

    def initialize(options = {})
      @config = Config.new(options)
      @api    = API.new(@config)
    end

    def bucket(bucket_name)
      Bucket.new(self, bucket_name)
    end

  end

  class Bucket

    attr_reader :client, :bucket_name

    def initialize(client, bucket_name)
      @client      = client
      @bucket_name = bucket_name
    end

    def list(path = '', options = {})
      Resource.new(self, bucket_name, path, options).to_enum
    end

    alias :ls :list

    def upload

    end

    def update

    end

    def delete

    end

  end

end