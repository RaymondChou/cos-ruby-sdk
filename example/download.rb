# coding: utf-8

$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

require 'cos'

# 初始化
COS::Logging::set_logger(STDOUT, Logger::DEBUG)

@client = COS.client(config: '~/.cos.yml')
@bucket = @client.bucket

# 下载文件
puts @bucket.download('/test/file', '~/save_file')

# 分块上传设置大小
file = @bucket.download('/test/file', '~/test.txt', slice_size: 5*1024*1024) do |pr|
  puts "下载进度 #{(pr*100).round(2)}%"
end
puts file

# 下载目录下的全部文件
files = @bucket.download_all('/test/', '~/my_path')
puts files

# 使用RAW API
@client.api.download('/test/file', '~/test.txt')