# coding: utf-8
# 下载集成测试

require 'minitest/autorun'
require 'benchmark'
require 'memory_profiler'

$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))

require 'cos'

class DownloadTest < Minitest::Test

  def setup
    @bucket     = COS.client(config: '~/.cos.yml').bucket
    @file_store = '~/Desktop/download_test/1.5GB.bin'
  end

  def test_download_big_file
    skip

    memory_profiler do

      Benchmark.bm(32) do |bm|
        bm.report('Slice Download 1.5GB File') do
          @bucket.download('test/1.5GB.bin', @file_store)
        end
      end

    end
  end

  private

  def memory_profiler
    report = MemoryProfiler.report do
      yield if block_given?
    end

    # 打印内存信息
    report.pretty_print
  end

end
