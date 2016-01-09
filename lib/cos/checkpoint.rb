# coding: utf-8

require 'json'

module COS

  class Checkpoint < Struct::Base

    # 默认线程数 10
    DEFAULT_THREADS = 10

    def initialize(options = {})
      super(options)

      # 分片大小必须>0
      if options[:options] and options[:options][:slice_size] and options[:options][:slice_size] <= 0
        raise ClientError, 'slice_size must > 0'
      end

      @mutex = Mutex.new
      @file_meta   = {}
      @num_threads = options[:threads] || DEFAULT_THREADS
      @all_mutex   = Mutex.new
      @parts       = []
      @todo_mutex  = Mutex.new
      @todo_parts  = []
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