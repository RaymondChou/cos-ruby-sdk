# coding: utf-8

$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

require 'cos'

# 初始化
COS::Logging::set_logger(STDOUT, Logger::DEBUG)

@client = COS.client(config: '~/.cos.yml')
@bucket = @client.bucket

# 更新文件或目录业务属性
@bucket.update('test/file1', 'new biz attr')

# 使用RAW API
@client.api.update('test/file1', 'new biz attr')