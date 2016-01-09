# coding: utf-8

require 'spec_helper'

module COS

  describe Util do

    # 测试文件sha1是否正确
    it 'should get correct file sha1' do
      file = './file_to_test.log'
      File.open(file, 'w') do |f|
        (1..10).each do |i|
          f.puts i.to_s.rjust(9, '0')
        end
      end
      result = Util.file_sha1(file)
      expect(result).to eq('0ee35e888cafa2e9644ddaa421ad44486abd7cf7')
    end

    # 测试字符串sha1是否正确
    it 'should get correct string sha1' do
      value = ''
      result = Util.string_sha1(value)
      expect(result).to eq('da39a3ee5e6b4b0d3255bfef95601890afd80709')

      value = 'aaaaaa bbbbbb cccccc'
      result = Util.string_sha1(value)
      expect(result).to eq('24662fa2abcb5cfb57f3e889216647c2cac06d31')
    end

    # 测试解析list时的path
    it 'should get correct list path' do
      result = Util.get_list_path('/path1/', 'file', true)
      expect(result).to eq('/path1/file')

      result = Util.get_list_path('/path1', 'file', true)
      expect(result).to eq('/path1/file')

      result = Util.get_list_path('path1', 'file', true)
      expect(result).to eq('/path1/file')

      result = Util.get_list_path('/path1/', 'path2')
      expect(result).to eq('/path1/path2/')

      result = Util.get_list_path('path1', 'path2')
      expect(result).to eq('/path1/path2/')
    end

    # 测试获取resource_path
    it 'should get correct resource_path' do
      result = Util.get_resource_path('10000', 'bucket', 'path1')
      expect(result).to eq('/10000/bucket/path1/')

      result = Util.get_resource_path('10000', 'bucket', '/path1/')
      expect(result).to eq('/10000/bucket/path1/')

      result = Util.get_resource_path('10000', 'bucket', 'path1', 'file1')
      expect(result).to eq('/10000/bucket/path1/file1')

      result = Util.get_resource_path('10000', 'bucket', '/path1/', 'file1')
      expect(result).to eq('/10000/bucket/path1/file1')

      expect do
        Util.get_resource_path('10000', 'bucket', '/path1/', 'file1/')
      end.to raise_error(ClientError, "File name can't start or end with '/'")

      expect do
        Util.get_resource_path('10000', 'bucket', '/path1/', '/file1')
      end.to raise_error(ClientError, "File name can't start or end with '/'")

    end

    # 测试获取resource_path包含文件
    it 'should get correct resource_path_or_file' do
      result = Util.get_resource_path_or_file('10000', 'bucket', 'file')
      expect(result).to eq('/10000/bucket/file')

      result = Util.get_resource_path_or_file('10000', 'bucket', 'path1/')
      expect(result).to eq('/10000/bucket/path1/')

      result = Util.get_resource_path_or_file('10000', 'bucket', '/path1/')
      expect(result).to eq('/10000/bucket/path1/')

      result = Util.get_resource_path_or_file('10000', 'bucket', '/path1/file')
      expect(result).to eq('/10000/bucket/path1/file')

      result = Util.get_resource_path_or_file('10000', 'bucket', 'path1/file')
      expect(result).to eq('/10000/bucket/path1/file')

    end

  end

end