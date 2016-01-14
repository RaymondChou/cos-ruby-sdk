# coding: utf-8

$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

require 'cos'

# 初始化
COS::Logging::set_logger(STDOUT, Logger::DEBUG)

@client = COS.client(config: '~/.cos.yml')
@bucket = @client.bucket

# 列举根目录
@bucket.list do |res|
  if res.is_a?(COS::COSDir)
    puts "Dir: #{res.name} #{res.path}"
  else
    puts "File: #{res.name} #{res.format_size}"
  end
end

# 只列举文件
@bucket.list('test', pattern: :file_only) do |res|
  puts "File: #{res.name} #{res.format_size}"
end

# 只列举目录
@bucket.list('test', pattern: :dir_only, order: :desc) do |res|
  puts "Dir: #{res.name} #{res.path}"
end

# 前缀搜索
@bucket.list('/', prefix: 'test_') do |res|
  if res.is_a?(COS::COSDir)
    puts "Dir: #{res.name} #{res.path}"
  else
    puts "File: #{res.name} #{res.format_size}"
  end
end

# 使用RAW API
puts @client.api.list('/test', pattern: :dir_only, order: :desc, prefix: 'abc', context: '')