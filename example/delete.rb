# coding: utf-8

$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

require 'cos'

# 初始化
COS::Logging::set_logger(STDOUT, Logger::DEBUG)

@client = COS.client(config: '~/.cos.yml')
@bucket = @client.bucket

# 删除文件或目录
@bucket.delete('test/file1')

puts @bucket.delete!('test')

# 使用RAW API
@client.api.delete('test/file1')