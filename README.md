# Tencent COS Ruby SDK

[![Gem Version](https://badge.fury.io/rb/cos.svg)](https://badge.fury.io/rb/cos)

-----

Tencent🐧 COS(Cloud Object Service) SDK for Ruby  [腾讯云对象存储服务](http://wiki.qcloud.com/wiki/COS%E4%BA%A7%E5%93%81%E4%BB%8B%E7%BB%8D)

## 运行环境

- Ruby版本 >= 1.9.3
- 操作系统：Windows/Linux/OS X

## 安装SDK

添加至应用程序的Gemfile文件：

``` ruby
gem 'cos'
```

然后执行：

``` 
$ bundle
```

或手动安装gem：

``` 
$ gem install cos
```

## 快速入门

### 准备工作

在[腾讯云COS控制台](http://console.qcloud.com/cos)创建Bucket并获取您的`app_id` `secret_id` `secret_key` 

🔍具体操作可参考[COS控制台使用说明](http://www.qcloud.com/wiki/COS%E6%8E%A7%E5%88%B6%E5%8F%B0%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E)

### 初始化与配置

``` ruby
require 'cos'

client = COS::Client.new({
  app_id:     'your_app_id',
  secret_id:  'your_secret_id',
  secret_key: 'your_secret_key'
})
```

更多参数请见：

### 指定Bucket

``` ruby
bucket = client.bucket('your_bucket_name')
```

🎉【Tip】如果你的项目只使用一个Bucket，也可以在初始化Client时通过`default_bucket`参数设置默认的Bucket：

``` ruby
client = COS::Client.new({
  app_id:         'your_app_id',
  secret_id:      'your_secret_id',
  secret_key:     'your_secret_key',
  defualt_bucket: 'your_default_bucket'
})
# 取得默认Bucket
bucket = client.bucket
```

### 目录操作

``` ruby
# 列出根目录中的所有资源(目录及文件)
bucket.list do |res|
  if res.is_a?(COS::COSDir) # 或 res.type == 'dir'
  	puts "Dir：#{res.name}"
  else
    # 文件 COS::COSFile 或 res.type == 'dir'
    puts "File：#{res.name}"
  end
end
# 输出：
目录：path1
目录：path2
目录：path3
文件：file1
文件：file1

# 可以按路径列出资源
bucket.list('/path/path2/') { |r| puts r.name }
# 只列出文件
bucket.list('/path/path2/', :pattern => :only_file) { |r| puts r.name }
# 只列出目录
bucket.list('/path/path2/', :pattern => :only_dir) { |r| puts r.name }
```

### 文件操作



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/cos.