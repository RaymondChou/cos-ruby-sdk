# coding: utf-8

$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

require 'cos'

# 初始化
COS::Logging::set_logger(STDOUT, Logger::DEBUG)

@client = COS.client(config: '~/.cos.yml')
@bucket = @client.bucket

# 上传文件
file = @bucket.upload('/test', 'file1.txt', '~/test.txt', biz_attr: 'test file')
puts file.name
puts file.format_size

# 大文件设置分割大小
file = @bucket.upload('/test', 'file1.txt', '~/test.txt', slice_size: 2*1024*1024) do |pr|
  puts "上传进度 #{(pr*100).round(2)}%"
end
puts file.name
puts file.format_size

# 使用单线程
file = @bucket.upload('/test', 'file1.txt', '~/test.txt', threads: 1) do |pr|
  puts "上传进度 #{(pr*100).round(2)}%"
end
puts file.name
puts file.format_size

# 批量上传目录中的文件
files = @bucket.upload_all('/test', '~/file_path') do |pr|
  puts "上传进度 #{(pr*100).round(2)}%"
end
puts files

# 使用RAW API完整上传
puts @client.api.upload('/test', 'file1.txt', '~/test.txt')

# 使用RAW API分块上传
puts @client.api.upload_slice('/test', 'file1.txt', '~/test.txt') do |pr|
  puts "上传进度 #{(pr*100).round(2)}%"
end
