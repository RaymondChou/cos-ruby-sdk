# coding: utf-8
# 上传集成测试

require 'minitest/autorun'
require 'benchmark'
require 'memory_profiler'

$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))

require 'cos'

class UploadTest < Minitest::Test

  def setup
    @bucket   = COS.client(config: '~/.cos.yml').bucket
    @file_src = '~/Desktop/upload_test/1.5GB.bin'
  end

  def test_upload_big_file
    skip

    memory_profiler do

      Benchmark.bm(32) do |bm|
        bm.report('Slice Upload 1.5GB File') do
          # 修改文件防止秒传命中
          `echo 1 >> #{@file_src}`
          # 删除文件
          @bucket.delete!('test/1.5GB.bin')
          @bucket.upload('test/', '1.5GB.bin', @file_src, auto_create_folder: true)
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
