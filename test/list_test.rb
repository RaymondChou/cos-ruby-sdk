# coding: utf-8
# 列表集成测试

require 'minitest/autorun'
require 'benchmark'
require 'memory_profiler'

$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))

require 'cos'

class ListTest < Minitest::Test

  def setup
    @bucket = COS.client(config: '~/.cos.yml').bucket
  end

  def test_list_big_dir
    memory_profiler do

      Benchmark.bm(32) do |bm|
        bm.report('List a big dir') do
          @bucket.list('big_dir').each do |res|
            puts res.name
          end
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