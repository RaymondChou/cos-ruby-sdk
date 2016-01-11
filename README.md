# Tencent COS Ruby SDK

[![Gem Version](https://badge.fury.io/rb/cos.svg)](https://badge.fury.io/rb/cos) [![Dependency Status](https://gemnasium.com/bfcd58e8c449a47dcf4bd15e35806dc8.svg)](https://gemnasium.com/RaymondChou/cos-ruby-sdk) [![Code Climate](https://codeclimate.com/repos/5690d89cb1a7430e970051c5/badges/e1ec353330a7f9bb90a1/gpa.svg)](https://codeclimate.com/repos/5690d89cb1a7430e970051c5/feed) [![Build Status](https://travis-ci.com/RaymondChou/cos-ruby-sdk.svg?token=J7GcZgoty9nseAGRShu5&branch=master)](https://travis-ci.com/RaymondChou/cos-ruby-sdk) [![Test Coverage](https://codeclimate.com/repos/5690d89cb1a7430e970051c5/badges/e1ec353330a7f9bb90a1/coverage.svg)](https://codeclimate.com/repos/5690d89cb1a7430e970051c5/coverage)

[![Gitter](https://badges.gitter.im/RaymondChou/cos-ruby-sdk.svg)](https://gitter.im/RaymondChou/cos-ruby-sdk?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge) [![Gem Downloads](http://ruby-gem-downloads-badge.herokuapp.com/cos?type=total)](https://rubygems.org/gems/cos) [![Github Code](http://img.shields.io/badge/github-code-blue.svg)](https://github.com/RaymondChou/cos-ruby-sdk) [![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://rubydoc.info/github/RaymondChou/cos-ruby-sdk)


-----

Tencent🐧 COS(Cloud Object Service) SDK for Ruby  [腾讯云对象存储服务](http://wiki.qcloud.com/wiki/COS%E4%BA%A7%E5%93%81%E4%BB%8B%E7%BB%8D)

## 运行环境

- Ruby版本：MRI >= 1.9.3,  JRuby >= 1.9
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
  defualt_bucket: 'your_default_bucket',
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
    # 文件 COS::COSFile 或 res.type == 'file'
    puts "File：#{res.name}"
  end
end

# 可以按路径列出资源
bucket.list('/path/path2/') { |r| puts r.name }
# 只列出文件
bucket.list('/path/path2/', :pattern => :only_file) { |r| puts r.name }
# 只列出目录
bucket.list('/path/path2/', :pattern => :only_dir) { |r| puts r.name }
```

### 文件操作

``` ruby

```



## API详细说明





## 底层API（JSON）





## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/cos.