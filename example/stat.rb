# coding: utf-8

$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

require 'cos'

# 初始化
COS::Logging::set_logger(STDOUT, Logger::DEBUG)

@client = COS.client(config: '~/.cos.yml')
@bucket = @client.bucket

# 获取bucket属性
puts @bucket.stat.authority

# 获取目录属性
puts @bucket.stat('/test').name

# 获取文件属性
puts @bucket.stat('/test/file').size

# 使用RAW API
puts @client.api.stat('/test/file')