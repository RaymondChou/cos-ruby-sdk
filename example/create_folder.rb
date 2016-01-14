# coding: utf-8

$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

require 'cos'

# 初始化
COS::Logging::set_logger(STDOUT, Logger::DEBUG)

@client = COS.client(config: '~/.cos.yml')
@bucket = @client.bucket

@rand_dir = Time.now.to_i.to_s

# 创建目录, 设置业务属性
dir1 = @bucket.create_folder("test_dir1_#{@rand_dir}", biz_attr: '测试目录1')
puts dir1.name

# 使用别名
dir2 = @bucket.mkdir("test_dir2_#{@rand_dir}")
puts dir2.name

# 可以是带"/"开头或结尾的目录
dir3 = @bucket.create_folder("/test_dir3_#{@rand_dir}/")
puts dir3.name

# 可以是多层级目录
dir4 = @bucket.create_folder("/test_dir4_#{@rand_dir}/4_1/4_1_1")
puts dir4.name

# 使用RAW API
data = @client.api.create_folder("test_dir5_#{@rand_dir}", biz_attr: '测试目录5')
puts data