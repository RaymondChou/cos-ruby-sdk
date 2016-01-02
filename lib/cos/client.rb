module COS

  class Client

    attr_reader :config, :api

    def initialize(options = {})
      @config = Config.new(options)
      @api    = API.new(@config)
    end

  end

end