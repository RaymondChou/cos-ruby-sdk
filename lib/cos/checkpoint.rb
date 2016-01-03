require 'json'

module COS

  class Checkpoint < Struct::Base

    def initialize(options = {})
      super(options)

      @mutex = Mutex.new
    end

    private

    # 写入断点续传状态
    def write_checkpoint(states, file)
      sha1 = Util.string_sha1(states.to_json)

      @mutex.synchronize do
        File.open(file, 'w') do |f|
          f.write(states.merge(sha1: sha1).to_json)
        end
      end
    end

    # 加载断点续传状态
    def load_checkpoint(file)
      states = {}

      @mutex.synchronize do
        states = JSON.parse(File.read(file), symbolize_names: true)
      end
      sha1 = states.delete(:sha1)

      raise CheckpointBrokenError, 'Missing SHA1 in checkpoint.' unless sha1

      unless sha1 == Util.string_sha1(states.to_json)
        raise CheckpointBrokenError, 'Unmatched checkpoint SHA1'
      end

      states
    end

  end

end