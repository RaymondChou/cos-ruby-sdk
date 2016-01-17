# Tencent COS Ruby SDK

[![Gem Version](https://badge.fury.io/rb/cos.svg)](https://badge.fury.io/rb/cos) [![Dependency Status](https://gemnasium.com/bfcd58e8c449a47dcf4bd15e35806dc8.svg)](https://gemnasium.com/RaymondChou/cos-ruby-sdk) [![Code Climate](https://codeclimate.com/repos/5690d89cb1a7430e970051c5/badges/e1ec353330a7f9bb90a1/gpa.svg)](https://codeclimate.com/repos/5690d89cb1a7430e970051c5/feed) [![Build Status](https://travis-ci.com/RaymondChou/cos-ruby-sdk.svg?token=J7GcZgoty9nseAGRShu5&branch=master)](https://travis-ci.com/RaymondChou/cos-ruby-sdk) [![Test Coverage](https://codeclimate.com/repos/5690d89cb1a7430e970051c5/badges/e1ec353330a7f9bb90a1/coverage.svg)](https://codeclimate.com/repos/5690d89cb1a7430e970051c5/coverage)

[![Gitter](https://badges.gitter.im/RaymondChou/cos-ruby-sdk.svg)](https://gitter.im/RaymondChou/cos-ruby-sdk?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge) [![Gem Downloads](http://ruby-gem-downloads-badge.herokuapp.com/cos?type=total)](https://rubygems.org/gems/cos) [![Github Code](http://img.shields.io/badge/github-code-blue.svg)](https://github.com/RaymondChou/cos-ruby-sdk) [![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://rubydoc.info/github/RaymondChou/cos-ruby-sdk)



-----

Tencent🐧 COS(Cloud Object Service) SDK for Ruby  [腾讯云对象存储服务](http://wiki.qcloud.com/wiki/COS%E4%BA%A7%E5%93%81%E4%BB%8B%E7%BB%8D)

- 100%实现COS官方Restful API
- 符合Ruby使用习惯的链式操作
- 支持HTTPS
- 支持大文件自动多线程分片断点续传上传、下载
- 支持Rails
- 提供便捷的CLI工具

## 1 运行环境

- Ruby版本：MRI >= 1.9.3,  JRuby >= 1.9
- 操作系统：Windows/Linux/OS X

## 2 安装SDK

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

## 3 快速入门

### 3.1 准备工作

在[腾讯云COS控制台](http://console.qcloud.com/cos)创建Bucket并获取您的`app_id` `secret_id` `secret_key` 

🔍具体操作可参考[COS控制台使用说明](http://www.qcloud.com/wiki/COS%E6%8E%A7%E5%88%B6%E5%8F%B0%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E)

### 3.2 初始化

``` ruby
require 'cos'

client = COS::Client.new({
  app_id:     'your_app_id',
  secret_id:  'your_secret_id',
  secret_key: 'your_secret_key',
  protocol:   'https' # 使用https
})
```

更多初始化参数及加载方式请见：4.1 初始化与配置

### 3.3 指定Bucket

``` ruby
bucket = client.bucket('your_bucket_name')
```

🎉【Tip】你也可以在初始化Client时通过`default_bucket`参数设置默认的Bucket：

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

### 3.4 目录操作示例

``` ruby
# 列举bucket根目录中的文件与目录
bucket.list do |res|
  if res.is_a?(COS::COSDir) # 或 res.type == 'dir'
    puts "Dir：#{res.name} #{res.biz_attr}"
    # 设置目录属性
    res.update('属性1')
  else
    # 文件 COS::COSFile 或 res.type == 'file'
    puts "File：#{res.name}"
    # 输出Hash参数
    puts res.to_hash
  end
end

# 可以按路径列出资源
bucket.list('/path/path2/') { |r| puts r.name }

# 只列出文件
bucket.list('/path/path2/', :pattern => :only_file) { |r| puts r.name }

# 倒序只列出目录
bucket.list('/path/path2/', :pattern => :only_dir, :order => :desc) { |r| puts r.name }

# 获取bucket信息
b = bucket.stat
puts b.refers

# 判断目录是否存在
puts bucket.exist?('dir')
# 获取目录信息
dir = bucket.stat('dir')
# 创建时间修改时间
puts dir.created_at
puts dir.updated_at
# 判断目录是否是空的
puts dir.empty?
# 目录中的文件及目录总数
puts dir.count
# 目录中的文件总数
puts dir.count_files
# 目录中的文件夹总数
puts dir.count_dirs
# 获取目录的树形结构
puts dir.hash_tree.to_json
# 删除目录
puts dir.delete!
# 上传文件至目录, 自动大文件分片多线程断点续传
dir.upload('file2', '~/path2/file2')
# 批量上传文件至目录，自动大文件分片多线程断点续传
dir.upload_all('~/path1')
# 下载目录中的所有文件，自动大文件分片多线程断点续传
puts bucket.stat('path3').download_all('~/path_store')
```

### 3.5 文件操作示例

``` ruby
# 上传文件，自动大文件分片多线程断点续传
file = bucket.upload('path', 'file1', '~/local_path/file1') do |pr|
  puts "上传进度 #{(pr*100).round(2)}%"
end
# 判断文件是否存在
puts bucket.exist?('path/file1')
# 获取文件信息
file = bucket.stat('path/file1')
puts file.name
puts file.biz_attr
# 更新文件属性
file.update('i am a biz attr')
# 判断文件是否上传完成
puts file.complete?
# 获取文件大小
puts file.size # file.file_size OR file.filesize
# 获取文件格式化的文件大小
puts file.format_size # 102KB, 3.1MB, 1.5GB
# 下载文件，自动大文件分片多线程断点续传
file.download('~/path/file1') do |pr|
  puts "下载进度 #{(pr*100).round(2)}%"
end
# 获取文件访问URL，私有读取bucket自动添加签名
file.url(cname: 's.domain.com')
# 删除文件
file.delete
```



## 4 SDK详细说明

### 4.1 初始化与配置

- 4.1.1 详细参数
  
  ``` ruby
  {
    # COS分配的app_id
    :app_id => 'app_id',
    # COS分配的secret_id
    :secret_id => 'secret_id',
    # COS分配的secret_key
    :secret_key => 'secret_key',
    # COS Reatful API Host
    :host => 'web.file.myqcloud.com',
    # 使用协议,默认为http,可选https
    :protocol => 'https',
    # 接口通讯建立连接超时秒数
    :open_timeout => 15,
    # 接口通讯读取数据超时秒数
    :read_timeout => 120,
    # 加载配置文件路径
    :config => '~/path/cos.yml',
    # 日志输出位置，可以是文件路径也可为STDOUT、STDERR
    :log_src => '/var/log/cos.log',
    # 输出日志级别
    :log_level => Logger::INFO,
    # 默认bucket
    :default_bucket => 'bucket_name',
    # 多次签名过期时间(单位秒)
    :multiple_sign_expire => 300
  }
  ```


- 4.1.2 标准方式初始化配置
  
  ``` ruby
  require 'cos'
  
  @client = COS::Client.new(configs)
  ```
  
- 4.1.3 实例方式初始化配置
  
  ``` ruby
  require 'cos'
  
  # 程序启动时加载配置
  COS.client(configs)
  # 使用client
  COS.client.bucket
  ```
  
- 4.1.4 从配置文件加载配置
  
  ``` ruby
  require 'cos'
  
  @client = COS::Client.new(config: './cos.yml')
  # 或
  COS.client(config: './cos.yml')
  ```
  
  Rails中会自动加载项目目录下的配置文件`log/cos.yml`
  
  🎉【Tip】可以使用CLI指令`cos init`创建默认的yml配置文件，`cos init [配置文件路径]`自定义配置文件的路径。

### 4.2 指定Bucket

所有的资源基本操作是基于一个bucket的，所有我们需要先指定一个bucket：

``` ruby
@bucket = @client.bucket('bucket_name')
# 或使用配置的默认bucket
@bucket = @client.bucket
```

注：指定bucket时，SDK会获取一次bucket信息，获取权限类型等信息，如bucket不存在将会抛出异常。

### 4.3 Bucket操作（COS::Bucket）

#### 4.3.1 获取Bucket属性

``` ruby
# bucket名称
puts @bucket.bucket_name
# bucket权限
puts @bucket.authority
```

| 属性                    | 类型            | 描述                                     |
| --------------------- | ------------- | -------------------------------------- |
| bucket_name           | String        | bucket名称                               |
| authority             | String        | eWPrivateRPublic私有写公共读，eWPrivate私有写私有读 |
| bucket_type           | Integer       | bucket_type                            |
| migrate_source_domain | String        | 回源地址                                   |
| need_preview          | String        | need_preview                           |
| refers                | Array<String> | refers                                 |
| blackrefers           | Array<String> | blackrefers                            |
| cnames                | Array<String> | cnames                                 |
| nugc_flag             | String        | nugc_flag                              |

#### 4.3.2 创建目录（create_folder，mkdir）

``` ruby
@bucket.create_folder(path, options = {}) # 方法别名mkdir
```

参数：

| 参数名                |   类型   |  必须  | 默认值  | 参数描述                                     |
| :----------------- | :----: | :--: | :--: | ---------------------------------------- |
| path               | String |  是   |  无   | 需要创建的目录路径, 如: 'path1', 'path1/path2', sdk会补齐末尾的 '/'。 |
| options            |  Hash  |      |      |                                          |
| options[:biz_attr] | String |  否   |  无   | 目录属性, 业务端维护                              |

返回：

``` ruby
COS::COSDir # 详见目录操作（COS::COSDir）
```

示例：

``` ruby
@bucket.create_folder("test_dir1", biz_attr: '测试目录1')
```

更多示例详见：example/create_folder.rb

#### 4.3.3 列举目录（list，ls）

``` ruby
@bucket.list(path = '', options = {}) # 方法别名ls
```

参数：

| 参数名               |   类型    |  必须  |  默认值  | 参数描述                                     |
| :---------------- | :-----: | :--: | :---: | ---------------------------------------- |
| path              | String  |  否   |   空   | 需要列举的目录路径, 如: 'path1', 'path1/path2', sdk会补齐末尾的 '/'。 |
| options           |  Hash   |      |       |                                          |
| options[:prefix]  | String  |  否   |   无   | 搜索前缀，如果填写prefix, 则列出含此前缀的所有文件及目录         |
| options[:num]     | Integer |  否   |  20   |                                          |
| options[:pattern] | Symbol  |  否   | :both | 获取模式，:dir_only 只获取目录, :file_only 只获取文件, 默认为 :both 全部获取 |
| options[:order]   | Symbol  |  否   | :asc  | 排序方式 :asc 正序, :desc 倒序 默认为 :asc          |

返回：

``` ruby
[Enumerator<Object>] 迭代器, 其中Object可能是COS::COSFile或COS::COSDir
```

示例：

``` ruby
@bucket.list('test') do |res|
  if res.is_a?(COS::COSDir)
    puts "Dir: #{res.name} #{res.path}"
  else
    puts "File: #{res.name} #{res.format_size}"
  end
end
```

更多示例详见：example/list.rb

### 4.4 资源操作

#### 4.4.1 文件操作（COS::COSFile）



#### 4.4.2 目录操作（COS::COSDir）





## 5 使用底层API

### 5.1 创建目录

### 5.2 目录列表（前缀搜索）

### 5.3 上传文件

### 5.4 上传文件（分片上传）

### 5.5 更新文件、目录属性

### 5.6 删除文件、目录 



## 6 CLI命令行工具

SDK提供了一套包含所有API调用的CLI工具，方便开发者更好的调试与更便捷的使用COS。

获取CLI指令列表：

``` shell
$ cos

COS Ruby SDK CLI commands:
  cos count [PATH]                           # 获取文件及目录数
  cos count_dirs [PATH]                      # 获取目录数
  cos count_files [PATH]                     # 获取文件数
  cos create_folder [PATH]                   # 创建目录
  cos delete [PATH]                          # 删除目录或文件
  cos download [PATH] [FILE_STORE]           # 下载文件(大文件自动分片下载,支持多线程断点续传)
  cos download_all [PATH] [FILE_STORE_PATH]  # 下载目录下的所有文件(不含子目录)
  cos exist [PATH]                           # 判断文件或目录是否存在
  cos help [COMMAND]                         # 获取指令的使用帮助
  cos init                                   # 创建默认配置文件
  cos is_complete [PATH]                     # 判断文件是否上传完整
  cos is_empty [PATH]                        # 判断目录是否为空
  cos list [PATH]                            # 获取目录列表
  cos sign_multi [EXPIRE]                    # 生成多次可用签名
  cos sign_once [PATH]                       # 生成单次可用签名
  cos stat [PATH]                            # 获取目录或文件信息
  cos tree [PATH]                            # 显示树形结构
  cos update [PATH] [BIZ_ATTR]               # 更新业务属性
  cos upload [PATH] [FILE_NAME] [FILE_SRC]   # 上传文件(大文件自动分片上传,支持多线程断点续传)
  cos upload_all [PATH] [FILE_SRC_PATH]      # 上传目录下的所有文件(不含子目录)
  cos url [PATH]                             # 获取文件的访问URL

Options:
  -c, [--config=CONFIG]  # 加载配置文件
                         # Default: ~/.cos.yml
  -b, [--bucket=BUCKET]  # 指定Bucket
```

获取指令的详细参数如：

``` shell
$ cos help upload

Usage:
  cos upload [PATH] [FILE_NAME] [FILE_SRC]

Options:
  -r, [--biz-attr=BIZ_ATTR]                              # 业务属性
  -m, [--min-slice-size=bytes]                           # 最小完整上传大小
  -f, [--auto-create-folder], [--no-auto-create-folder]  # 自动创建目录
  -d, [--disable-cpt], [--no-disable-cpt]                # 禁用断点续传(分片上传时有效)
  -t, [--threads=N]                                      # 线程数(分片上传时有效)
  -n, [--upload-retry=N]                                 # 重试次数(分片上传时有效)
  -s, [--slice-size=N]                                   # 分片上传时每个分片的大小(分片上传时有效)
  -e, [--cpt-file=CPT_FILE]                              # 指定断点续传记录(分片上传时有效)
  -c, [--config=CONFIG]                                  # 加载配置文件
                                                         # Default: ~/.cos.yml
  -b, [--bucket=BUCKET]                                  # 指定Bucket

上传文件(大文件自动分片上传,支持多线程上传,断点续传)
```

初始化创建配置文件：(默认创建于`~/.cos.yml`)

``` shell
$ cos init
```

使用CLI:

``` shell
$ cos upload path/path2 file1 ~/file1
```

## 7 运行测试

``` 
rspec
```

或

``` 
bundle exec rake spec
```