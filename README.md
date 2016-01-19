# Tencent COS Ruby SDK

[![Gem Version](https://badge.fury.io/rb/cos.svg)](https://badge.fury.io/rb/cos) [![Dependency Status](https://gemnasium.com/RaymondChou/cos-ruby-sdk.svg)](https://gemnasium.com/RaymondChou/cos-ruby-sdk)
 [![Code Climate](https://codeclimate.com/github/RaymondChou/cos-ruby-sdk/badges/gpa.svg)](https://codeclimate.com/github/RaymondChou/cos-ruby-sdk) [![Build Status](https://travis-ci.org/RaymondChou/cos-ruby-sdk.svg?branch=master)](https://travis-ci.org/RaymondChou/cos-ruby-sdk) [![Test Coverage](https://codeclimate.com/github/RaymondChou/cos-ruby-sdk/badges/coverage.svg)](https://codeclimate.com/github/RaymondChou/cos-ruby-sdk/coverage)

[![Gitter](https://badges.gitter.im/RaymondChou/cos-ruby-sdk.svg)](https://gitter.im/RaymondChou/cos-ruby-sdk?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge) [![Gem Downloads](http://ruby-gem-downloads-badge.herokuapp.com/cos?type=total)](https://rubygems.org/gems/cos) [![Github Code](http://img.shields.io/badge/github-code-blue.svg)](https://github.com/RaymondChou/cos-ruby-sdk) [![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://rubydoc.info/github/RaymondChou/cos-ruby-sdk)



-----

Tencent🐧 COS(Cloud Object Service) SDK for Ruby  [腾讯云对象存储服务](http://wiki.qcloud.com/wiki/COS%E4%BA%A7%E5%93%81%E4%BB%8B%E7%BB%8D)

- 100%实现COS官方Restful API
  
- 符合Ruby使用习惯的链式操作
  
- 支持HTTPS
  
- 支持大文件自动多线程分片断点续传上传、下载
  
- 支持Rails
  
- 提供便捷的[CLI工具:](#6-cli%E5%91%BD%E4%BB%A4%E8%A1%8C%E5%B7%A5%E5%85%B7)
  
  ![CLI示例](http://mytest-10016219.file.myqcloud.com/out2.gif)

**目录**

- [Tencent COS Ruby SDK](#tencent-cos-ruby-sdk)
  - [1 运行环境](#1-%E8%BF%90%E8%A1%8C%E7%8E%AF%E5%A2%83)
  - [2 安装SDK](#2-%E5%AE%89%E8%A3%85sdk)
  - [3 快速入门](#3-%E5%BF%AB%E9%80%9F%E5%85%A5%E9%97%A8)
    - [3.1 准备工作](#31-%E5%87%86%E5%A4%87%E5%B7%A5%E4%BD%9C)
    - [3.2 初始化](#32-%E5%88%9D%E5%A7%8B%E5%8C%96)
    - [3.3 指定Bucket](#33-%E6%8C%87%E5%AE%9Abucket)
    - [3.4 目录操作示例](#34-%E7%9B%AE%E5%BD%95%E6%93%8D%E4%BD%9C%E7%A4%BA%E4%BE%8B)
    - [3.5 文件操作示例](#35-%E6%96%87%E4%BB%B6%E6%93%8D%E4%BD%9C%E7%A4%BA%E4%BE%8B)
  - [4 SDK详细说明](#4-sdk%E8%AF%A6%E7%BB%86%E8%AF%B4%E6%98%8E)
    - [4.1 初始化与配置](#41-%E5%88%9D%E5%A7%8B%E5%8C%96%E4%B8%8E%E9%85%8D%E7%BD%AE)
    - [4.2 指定Bucket](#42-%E6%8C%87%E5%AE%9Abucket)
    - [4.3 Bucket操作（COS::Bucket）](#43-bucket%E6%93%8D%E4%BD%9Ccosbucket)
      - [4.3.1 获取Bucket属性](#431-%E8%8E%B7%E5%8F%96bucket%E5%B1%9E%E6%80%A7)
      - [4.3.2 创建目录（create_folder，mkdir）](#432-%E5%88%9B%E5%BB%BA%E7%9B%AE%E5%BD%95create_folder)
      - [4.3.3 列举目录（list，ls）](#433-%E5%88%97%E4%B8%BE%E7%9B%AE%E5%BD%95list%EF%BC%8Cls)
      - [4.3.4 上传文件（upload）](#434-%E4%B8%8A%E4%BC%A0%E6%96%87%E4%BB%B6upload)
      - [4.3.4 资源属性（stat）](#434-%E8%B5%84%E6%BA%90%E5%B1%9E%E6%80%A7stat)
      - [4.3.5 更新资源属性（upadte）](#435-%E6%9B%B4%E6%96%B0%E8%B5%84%E6%BA%90%E5%B1%9E%E6%80%A7upadte)
      - [4.3.6 删除资源（delete）](#436-%E5%88%A0%E9%99%A4%E8%B5%84%E6%BA%90delete)
      - [4.3.7 删除资源（无异常）（delete!）](#437-%E5%88%A0%E9%99%A4%E8%B5%84%E6%BA%90%E6%97%A0%E5%BC%82%E5%B8%B8delete)
      - [4.3.8 判断目录是否为空（empty?）](#438-%E5%88%A4%E6%96%AD%E7%9B%AE%E5%BD%95%E6%98%AF%E5%90%A6%E4%B8%BA%E7%A9%BAempty)
      - [4.3.9 判断资源是否存在（exist?，exists?）](#439-%E5%88%A4%E6%96%AD%E8%B5%84%E6%BA%90%E6%98%AF%E5%90%A6%E5%AD%98%E5%9C%A8exist%EF%BC%8Cexists)
      - [4.3.9 判断文件是否上传完成（complete?）](#439-%E5%88%A4%E6%96%AD%E6%96%87%E4%BB%B6%E6%98%AF%E5%90%A6%E4%B8%8A%E4%BC%A0%E5%AE%8C%E6%88%90complete)
      - [4.3.10 获取文件的访问URL（url）](#4310-%E8%8E%B7%E5%8F%96%E6%96%87%E4%BB%B6%E7%9A%84%E8%AE%BF%E9%97%AEurlurl)
      - [4.3.11 下载文件（download）](#4311-%E4%B8%8B%E8%BD%BD%E6%96%87%E4%BB%B6download)
      - [4.3.12 获取Object树形结构（tree）](#4312-%E8%8E%B7%E5%8F%96object%E6%A0%91%E5%BD%A2%E7%BB%93%E6%9E%84tree)
      - [4.3.13 获取Hash树形结构（hash_tree）](#4313-%E8%8E%B7%E5%8F%96hash%E6%A0%91%E5%BD%A2%E7%BB%93%E6%9E%84hash_tree)
      - [4.3.14 批量下载目录下的所有文件（download_all）](#4314-%E6%89%B9%E9%87%8F%E4%B8%8B%E8%BD%BD%E7%9B%AE%E5%BD%95%E4%B8%8B%E7%9A%84%E6%89%80%E6%9C%89%E6%96%87%E4%BB%B6download_all)
      - [4.3.15 批量上传目录中的所有文件（upload_all）](#4315-%E6%89%B9%E9%87%8F%E4%B8%8A%E4%BC%A0%E7%9B%AE%E5%BD%95%E4%B8%AD%E7%9A%84%E6%89%80%E6%9C%89%E6%96%87%E4%BB%B6upload_all)
      - [4.3.16 获取资源个数详情（支持前缀搜索）（list_count）](#4316-%E8%8E%B7%E5%8F%96%E8%B5%84%E6%BA%90%E4%B8%AA%E6%95%B0%E8%AF%A6%E6%83%85%E6%94%AF%E6%8C%81%E5%89%8D%E7%BC%80%E6%90%9C%E7%B4%A2list_count)
      - [4.3.17 获取资源个数（count, size）](#4317-%E8%8E%B7%E5%8F%96%E8%B5%84%E6%BA%90%E4%B8%AA%E6%95%B0count-size)
      - [4.3.18 获取文件个数（count_files）](#4318-%E8%8E%B7%E5%8F%96%E6%96%87%E4%BB%B6%E4%B8%AA%E6%95%B0count_files)
      - [4.3.19 获取目录个数（count_dirs）](#4319-%E8%8E%B7%E5%8F%96%E7%9B%AE%E5%BD%95%E4%B8%AA%E6%95%B0count_dirs)
    - [4.4 资源操作](#44-%E8%B5%84%E6%BA%90%E6%93%8D%E4%BD%9C)
      - [4.4.1 文件操作（COS::COSFile）](#441-%E6%96%87%E4%BB%B6%E6%93%8D%E4%BD%9Ccoscosfile)
        - [4.4.1.1 获取文件属性](#4411-%E8%8E%B7%E5%8F%96%E6%96%87%E4%BB%B6%E5%B1%9E%E6%80%A7)
        - [4.4.1.2 获取当前文件属性（刷新）（stat）](#4412-%E8%8E%B7%E5%8F%96%E5%BD%93%E5%89%8D%E6%96%87%E4%BB%B6%E5%B1%9E%E6%80%A7%E5%88%B7%E6%96%B0stat)
        - [4.4.1.3 更新当前文件属性（upadte）](#4413-%E6%9B%B4%E6%96%B0%E5%BD%93%E5%89%8D%E6%96%87%E4%BB%B6%E5%B1%9E%E6%80%A7upadte)
        - [4.4.1.4 删除当前文件（delete）](#4414-%E5%88%A0%E9%99%A4%E5%BD%93%E5%89%8D%E6%96%87%E4%BB%B6delete)
        - [4.4.1.5 删除当前文件（无异常）（delete!）](#4415-%E5%88%A0%E9%99%A4%E5%BD%93%E5%89%8D%E6%96%87%E4%BB%B6%E6%97%A0%E5%BC%82%E5%B8%B8delete)
        - [4.4.1.6 判断当前文件是否存在（exist?，exists?）](#4416-%E5%88%A4%E6%96%AD%E5%BD%93%E5%89%8D%E6%96%87%E4%BB%B6%E6%98%AF%E5%90%A6%E5%AD%98%E5%9C%A8exist%EF%BC%8Cexists)
        - [4.4.1.7 判断当前文件是否上传完成（complete?）](#4417-%E5%88%A4%E6%96%AD%E5%BD%93%E5%89%8D%E6%96%87%E4%BB%B6%E6%98%AF%E5%90%A6%E4%B8%8A%E4%BC%A0%E5%AE%8C%E6%88%90complete)
        - [4.4.1.8 获取当前文件的访问URL（url）](#4418-%E8%8E%B7%E5%8F%96%E5%BD%93%E5%89%8D%E6%96%87%E4%BB%B6%E7%9A%84%E8%AE%BF%E9%97%AEurlurl)
        - [4.4.1.9 下载当前文件（download）](#4419-%E4%B8%8B%E8%BD%BD%E5%BD%93%E5%89%8D%E6%96%87%E4%BB%B6download)
        - [4.4.1.10 判断当前文件与本地文件是否相同](#44110-%E5%88%A4%E6%96%AD%E5%BD%93%E5%89%8D%E6%96%87%E4%BB%B6%E4%B8%8E%E6%9C%AC%E5%9C%B0%E6%96%87%E4%BB%B6%E6%98%AF%E5%90%A6%E7%9B%B8%E5%90%8C)
      - [4.4.2 目录操作（COS::COSDir）](#442-%E7%9B%AE%E5%BD%95%E6%93%8D%E4%BD%9Ccoscosdir)
        - [4.4.2.1 获取目录属性](#4421-%E8%8E%B7%E5%8F%96%E7%9B%AE%E5%BD%95%E5%B1%9E%E6%80%A7)
        - [4.4.2.2 列举当前目录（前缀搜索）（list，ls）](#4422-%E5%88%97%E4%B8%BE%E5%BD%93%E5%89%8D%E7%9B%AE%E5%BD%95%E5%89%8D%E7%BC%80%E6%90%9C%E7%B4%A2list%EF%BC%8Cls)
        - [4.4.2.3 创建子目录（create_folder，mkdir）](#4423-%E5%88%9B%E5%BB%BA%E5%AD%90%E7%9B%AE%E5%BD%95create_folder)
        - [4.4.2.4 上传文件至当前目录（upload）](#4424-%E4%B8%8A%E4%BC%A0%E6%96%87%E4%BB%B6%E8%87%B3%E5%BD%93%E5%89%8D%E7%9B%AE%E5%BD%95upload)
        - [4.4.2.5 批量上传本地目录中的所有文件至当前目录（upload_all）](#4425-%E6%89%B9%E9%87%8F%E4%B8%8A%E4%BC%A0%E6%9C%AC%E5%9C%B0%E7%9B%AE%E5%BD%95%E4%B8%AD%E7%9A%84%E6%89%80%E6%9C%89%E6%96%87%E4%BB%B6%E8%87%B3%E5%BD%93%E5%89%8D%E7%9B%AE%E5%BD%95upload_all)
        - [4.4.2.6 批量下载当前目录下的所有文件（download_all）](#4426-%E6%89%B9%E9%87%8F%E4%B8%8B%E8%BD%BD%E5%BD%93%E5%89%8D%E7%9B%AE%E5%BD%95%E4%B8%8B%E7%9A%84%E6%89%80%E6%9C%89%E6%96%87%E4%BB%B6download_all)
        - [4.4.2.7 当前目录属性（刷新）（stat）](#4427-%E5%BD%93%E5%89%8D%E7%9B%AE%E5%BD%95%E5%B1%9E%E6%80%A7%E5%88%B7%E6%96%B0stat)
        - [4.4.2.8 更新当前目录属性（upadte）](#4428-%E6%9B%B4%E6%96%B0%E5%BD%93%E5%89%8D%E7%9B%AE%E5%BD%95%E5%B1%9E%E6%80%A7upadte)
        - [4.4.2.9 删除当前目录（delete）](#4429-%E5%88%A0%E9%99%A4%E5%BD%93%E5%89%8D%E7%9B%AE%E5%BD%95delete)
        - [4.4.2.10 删除当前目录（无异常）（delete!）](#44210-%E5%88%A0%E9%99%A4%E5%BD%93%E5%89%8D%E7%9B%AE%E5%BD%95%E6%97%A0%E5%BC%82%E5%B8%B8delete)
        - [4.4.2.11 判断当前目录是否为空（empty?）](#44211-%E5%88%A4%E6%96%AD%E5%BD%93%E5%89%8D%E7%9B%AE%E5%BD%95%E6%98%AF%E5%90%A6%E4%B8%BA%E7%A9%BAempty)
        - [4.4.2.12 判断当前目录是否存在（exist?，exists?）](#44212-%E5%88%A4%E6%96%AD%E5%BD%93%E5%89%8D%E7%9B%AE%E5%BD%95%E6%98%AF%E5%90%A6%E5%AD%98%E5%9C%A8exist%EF%BC%8Cexists)
        - [4.4.2.13 获取当前目录下的Object树形结构（tree）](#44213-%E8%8E%B7%E5%8F%96%E5%BD%93%E5%89%8D%E7%9B%AE%E5%BD%95%E4%B8%8B%E7%9A%84object%E6%A0%91%E5%BD%A2%E7%BB%93%E6%9E%84tree)
        - [4.4.2.14 获取当前目录下的Hash树形结构（hash_tree）](#44214-%E8%8E%B7%E5%8F%96%E5%BD%93%E5%89%8D%E7%9B%AE%E5%BD%95%E4%B8%8B%E7%9A%84hash%E6%A0%91%E5%BD%A2%E7%BB%93%E6%9E%84hash_tree)
        - [4.4.2.15 获取当前目录下的资源个数详情（支持前缀搜索）（list_count）](#44215-%E8%8E%B7%E5%8F%96%E5%BD%93%E5%89%8D%E7%9B%AE%E5%BD%95%E4%B8%8B%E7%9A%84%E8%B5%84%E6%BA%90%E4%B8%AA%E6%95%B0%E8%AF%A6%E6%83%85%E6%94%AF%E6%8C%81%E5%89%8D%E7%BC%80%E6%90%9C%E7%B4%A2list_count)
        - [4.4.2.16 获取当前目录下的资源个数（count, size）](#44216-%E8%8E%B7%E5%8F%96%E5%BD%93%E5%89%8D%E7%9B%AE%E5%BD%95%E4%B8%8B%E7%9A%84%E8%B5%84%E6%BA%90%E4%B8%AA%E6%95%B0count-size)
        - [4.4.2.17 获取当前目录下的文件个数（count_files）](#44217-%E8%8E%B7%E5%8F%96%E5%BD%93%E5%89%8D%E7%9B%AE%E5%BD%95%E4%B8%8B%E7%9A%84%E6%96%87%E4%BB%B6%E4%B8%AA%E6%95%B0count_files)
        - [4.4.2.18 获取当前目录下的子目录个数（count_dirs）](#44218-%E8%8E%B7%E5%8F%96%E5%BD%93%E5%89%8D%E7%9B%AE%E5%BD%95%E4%B8%8B%E7%9A%84%E5%AD%90%E7%9B%AE%E5%BD%95%E4%B8%AA%E6%95%B0count_dirs)
    - [4.5 签名操作（COS::Signature）](#45-%E7%AD%BE%E5%90%8D%E6%93%8D%E4%BD%9Ccossignature)
      - [4.5.1 获取单次有效签名（once）](#451-%E8%8E%B7%E5%8F%96%E5%8D%95%E6%AC%A1%E6%9C%89%E6%95%88%E7%AD%BE%E5%90%8Donce)
      - [4.5.2 获取多次有效签名（multiple）](#452-%E8%8E%B7%E5%8F%96%E5%A4%9A%E6%AC%A1%E6%9C%89%E6%95%88%E7%AD%BE%E5%90%8Dmultiple)
  - [5 底层API（COS::API）](#5-%E5%BA%95%E5%B1%82apicosapi)
    - [5.1 创建目录(create_folder)](#51-%E5%88%9B%E5%BB%BA%E7%9B%AE%E5%BD%95create_folder)
    - [5.2 目录列表（前缀搜索）(list)](#52-%E7%9B%AE%E5%BD%95%E5%88%97%E8%A1%A8%E5%89%8D%E7%BC%80%E6%90%9C%E7%B4%A2list)
    - [5.3 上传文件（完整上传）(upload)](#53-%E4%B8%8A%E4%BC%A0%E6%96%87%E4%BB%B6%E5%AE%8C%E6%95%B4%E4%B8%8A%E4%BC%A0upload)
    - [5.4 上传文件（分片上传）(upload_slice)](#54-%E4%B8%8A%E4%BC%A0%E6%96%87%E4%BB%B6%E5%88%86%E7%89%87%E4%B8%8A%E4%BC%A0upload_slice)
    - [5.5 更新文件、目录属性(update)](#55-%E6%9B%B4%E6%96%B0%E6%96%87%E4%BB%B6%E3%80%81%E7%9B%AE%E5%BD%95%E5%B1%9E%E6%80%A7update)
    - [5.6 删除文件、目录(delete)](#56-%E5%88%A0%E9%99%A4%E6%96%87%E4%BB%B6%E3%80%81%E7%9B%AE%E5%BD%95delete)
    - [5.7 获取文件或目录属性(stat)](#57-%E8%8E%B7%E5%8F%96%E6%96%87%E4%BB%B6%E6%88%96%E7%9B%AE%E5%BD%95%E5%B1%9E%E6%80%A7stat)
    - [5.8下载文件](#58%E4%B8%8B%E8%BD%BD%E6%96%87%E4%BB%B6)
  - [6 CLI命令行工具](#6-cli%E5%91%BD%E4%BB%A4%E8%A1%8C%E5%B7%A5%E5%85%B7)
  - [7 运行测试](#7-%E8%BF%90%E8%A1%8C%E6%B5%8B%E8%AF%95)

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

更多初始化参数及加载方式请见： [4.1 初始化与配置](#41-%E5%88%9D%E5%A7%8B%E5%8C%96%E4%B8%8E%E9%85%8D%E7%BD%AE)

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

#### 4.3.4 上传文件（upload）

``` ruby
@bucket.upload(path_or_dir, file_name, file_src, options = {}, &block)
```

参数：

| 参数名                          |         类型         |  必须  |       默认值        | 参数描述                                     |
| :--------------------------- | :----------------: | :--: | :--------------: | ---------------------------------------- |
| path_or_dir                  | String/COS::COSDir |  否   |        空         | 目录路径或目录对象COSDir目录路径如: '/', 'path1', 'path1/path2', sdk会补齐末尾的 '/' |
| file_name                    |       String       |  是   |        无         | 存储文件名                                    |
| file_src                     |       String       |  是   |        无         | 本地文件路径                                   |
| options                      |        Hash        |  否   |        无         |                                          |
| options[:auto_create_folder] |      Boolean       |  否   |      false       | 自动创建远端目录                                 |
| options[:min_slice_size]     |      Integer       |  否   | 10 * 1024 * 1024 | 完整上传最小文件大小,超过此大小将会使用分片多线程断点续传            |
| options[:upload_retry]       |      Integer       |  否   |        10        | 上传重试次数                                   |
| options[:biz_attr]           |       String       |  否   |        无         | 业务属性                                     |
| options[:disable_cpt]        |      Boolean       |  否   |      false       | 是否禁用checkpoint，如禁用仍可通过服务端进行断点续传          |
| options[:threads]            |      Integer       |  否   |        10        | 多线程上传线程数                                 |
| options[:slice_size]         |      Integer       |  否   | 3 * 1024 * 1024  | 设置分片上传时每个分片的大小。默认为3 MB, 目前服务端最大限制也为3MB。  |
| options[:cpt_file]           |       String       |  否   |        无         | 断点续传的checkpoint文件                        |
| yield                        |       Float        |  否   |        无         | 上传进度百分比回调, 进度值是一个0-1之间的小数                |

注：SDK会自动使用分片断点续传上传大文件。

返回：

``` ruby
COS::COSFile # 详见目录操作（COS::COSFile）
```

示例：

``` ruby
file = @bucket.upload('/test', 'file1.txt', '~/test.txt') do |pr|
  puts "上传进度 #{(pr*100).round(2)}%"
end
puts file.name
puts file.format_size
puts file.url
```

更多示例详见： example/upload.rb

#### 4.3.4 资源属性（stat）

``` ruby
@bucket.stat(path)
```

参数：

| 参数名  |   类型   |  必须  | 默认值  | 参数描述                                 |
| :--- | :----: | :--: | :--: | ------------------------------------ |
| path | String |  是   |  无   | 资源路径, 如: 目录'path1/', 文件'path1/file'。 |

返回：

``` ruby
可能是COS::COSFile(文件)或COS::COSDir(目录)
```

示例：

``` ruby
puts @bucket.stat('/test').name
```

更多示例详见： example/stat.rb

#### 4.3.5 更新资源属性（upadte）

``` ruby
@bucket.update(path, biz_attr)
```

参数：

| 参数名      |   类型   |  必须  | 默认值  | 参数描述                                 |
| :------- | :----: | :--: | :--: | ------------------------------------ |
| path     | String |  是   |  无   | 资源路径, 如: 目录'path1/', 文件'path1/file'。 |
| biz_attr | String |  是   |  无   | 业务属性                                 |

示例：

``` ruby
@bucket.update('test/file1', 'new biz attr')
```

更多示例详见： example/update.rb

#### 4.3.6 删除资源（delete）

``` ruby
@bucket.delete(path)
```

参数：

| 参数名  |   类型   |  必须  | 默认值  | 参数描述                                 |
| :--- | :----: | :--: | :--: | ------------------------------------ |
| path | String |  是   |  无   | 资源路径, 如: 目录'path1/', 文件'path1/file'。 |

注意：非空目录或根目录无法删除，会抛出异常

示例：

``` ruby
@bucket.delete('test/')
```

更多示例详见：example/delete.rb

#### 4.3.7 删除资源（无异常）（delete!）

``` ruby
@bucket.delete!(path)
```

参数：

| 参数名  |   类型   |  必须  | 默认值  | 参数描述                                 |
| :--- | :----: | :--: | :--: | ------------------------------------ |
| path | String |  是   |  无   | 资源路径, 如: 目录'path1/', 文件'path1/file'。 |

注意：非空目录或根目录无法删除，返回是否成功的bool值。

返回：

``` ruby
Boolean
```

示例：

``` ruby
puts @bucket.delete!('test/')
```

更多示例详见：example/delete.rb

#### 4.3.8 判断目录是否为空（empty?）

``` ruby
@bucket.empty?(path)
```

参数：

| 参数名  |   类型   |  必须  | 默认值  | 参数描述                                   |
| :--- | :----: | :--: | :--: | -------------------------------------- |
| path | String |  否   |  空   | 目录路径, 如: 目录'path1/'。如为空则会判断bucket是否为空。 |

返回：

``` ruby
Boolean
```

示例：

``` ruby
# 目录是否为空
puts @bucket.empty?('test/')
# bucket是否为空
puts @bucket.empty?
```

#### 4.3.9 判断资源是否存在（exist?，exists?）

``` ruby
@bucket.exist?(path) # 别名 exists?
```

参数：

| 参数名  |   类型   |  必须  | 默认值  | 参数描述                                |
| :--- | :----: | :--: | :--: | ----------------------------------- |
| path | String |  是   |  无   | 资源路径, 如: 目录'path1/', 文件'path1/file' |

返回：

``` ruby
Boolean
```

示例：

``` ruby
puts @bucket.exist?('test/')
puts @bucket.exist?('test/file1')
```

#### 4.3.9 判断文件是否上传完成（complete?）

``` ruby
@bucket.complete?(path)
```

参数：

| 参数名  |   类型   |  必须  | 默认值  | 参数描述                    |
| :--- | :----: | :--: | :--: | ----------------------- |
| path | String |  是   |  无   | 文件资源路径, 如: 'path1/file' |

返回：

``` ruby
Boolean
```

示例：

``` ruby
puts @bucket.complete?('path/file1')
```

#### 4.3.10 获取文件的访问URL（url）

``` ruby
@bucket.url(path_or_file, options = {})
```

参数：

| 参数名                      |         类型          |  必须  |  默认值  | 参数描述                            |
| :----------------------- | :-----------------: | :--: | :---: | ------------------------------- |
| path_or_file             | String/COS::COSFile |  否   |   空   | 文件资源COSFile或路径, 如: 'path1/file' |
| options                  |        Hash         |      |       |                                 |
| options[:cname]          |       String        |  否   |   无   | 获取使用cname的url。在cos控制台设置的cname域名 |
| options[:https]          |       Boolean       |  否   | false | 是否获取https的url                   |
| options[:expire_seconds] |       Integer       |  否   |  600  | 签名有效时间(秒,私有读取bucket时需要)         |

返回：

``` ruby
String
```

示例：

``` ruby
puts bucket.url('path1/file1', https: true, cname: 'static.domain.com')
```

#### 4.3.11 下载文件（download）

``` ruby
@bucket.download(path_or_file, file_store, options = {}, &block)
```

参数：

| 参数名                      |         类型          |  必须  |      默认值      | 参数描述                            |
| :----------------------- | :-----------------: | :--: | :-----------: | ------------------------------- |
| path_or_file             | String/COS::COSFile |  是   |       无       | 文件资源COSFile或路径, 如: 'path1/file' |
| file_store               |       String        |  是   |       无       | 本地文件存储路径                        |
| options                  |        Hash         |  否   |       无       |                                 |
| options[:disable_mkdir]  |       Boolean       |  否   |     true      | 禁止自动创建本地文件夹, 默认会创建              |
| options[:min_slice_size] |       Integer       |  否   | 5 * 10 * 1024 | 完整下载最小文件大小,超过此大小将会使用分片多线程断点续传   |
| options[:download_retry] |       Integer       |  否   |      10       | 下载重试次数                          |
| options[:disable_cpt]    |       Boolean       |  否   |     false     | 是否禁用checkpoint，如果禁用则不使用断点续传     |
| yield                    |        Float        |  否   |       无       | 下载进度百分比回调, 进度值是一个0-1之间的小数       |

注：支持私有访问资源下载，SDK会自动携带鉴权签名。SDK会自动使用分片断点续传下载大文件。

返回：

``` ruby
String # 本地文件存储路径
```

示例：

``` ruby
file = bucket.download('path/file1', '~/test/file1') do |p|
  puts "下载进度: #{(p*100).round(2)}%")
end
puts file
```

更多示例详见：example/download.rb

#### 4.3.12 获取Object树形结构（tree）

``` ruby
@bucket.tree(path_or_dir = '', options = {})
```

参数：

| 参数名             |         类型         |  必须  | 默认值  | 参数描述                                     |
| :-------------- | :----------------: | :--: | :--: | ---------------------------------------- |
| path_or_dir     | String/COS::COSDir |  否   |  空   | 目录路径或目录对象COSDir目录路径如: '/', 'path1', 'path1/path2', sdk会补齐末尾的 '/' |
| options         |        Hash        |      |      |                                          |
| options[:depth] |      Integer       |  否   |  5   | 子目录深度,默认为5                               |

返回：

``` 
{
    :resource => Object<COS::COSDir>,
    :children => [
    	{:resource => Object<COS::COSDir>, :children => [...]},
    	{:resource => Object<COS::COSFile>, :children => [...]},
    	...
    ]
}
```

示例：

``` ruby
tree = @bucket.tree
puts tree[:resource].name
tree[:children].each do |r|
  puts r[:resource].name
end
```

#### 4.3.13 获取Hash树形结构（hash_tree）

``` ruby
@bucket.hash_tree(path_or_dir = '', options = {})
```

参数：

| 参数名             |         类型         |  必须  | 默认值  | 参数描述                                     |
| :-------------- | :----------------: | :--: | :--: | ---------------------------------------- |
| path_or_dir     | String/COS::COSDir |  否   |  空   | 目录路径或目录对象COSDir目录路径如: '/', 'path1', 'path1/path2', sdk会补齐末尾的 '/' |
| options         |        Hash        |      |      |                                          |
| options[:depth] |      Integer       |  否   |  5   | 子目录深度,默认为5                               |

返回：

``` 
{
    :resource => {:name...},
    :children => [
    	{:resource => {:name...}, :children => [...]},
    	{:resource => {:name...}, :children => [...]},
    	...
    ]
}
```

示例：

``` ruby
tree = @bucket.hash_tree
puts tree[:resource][:name]
tree[:children].each do |r|
  puts r[:resource][:name]
end
puts tree.to_json # 可直接转为json
```

#### 4.3.14 批量下载目录下的所有文件（download_all）

``` ruby
@bucket.download_all(path_or_dir, file_store_path, options = {}, &block)
```

参数：

| 参数名                      |         类型         |  必须  |      默认值      | 参数描述                                     |
| :----------------------- | :----------------: | :--: | :-----------: | ---------------------------------------- |
| path_or_dir              | String/COS::COSDir |  否   |       空       | 目录路径或目录对象COSDir目录路径如: '/', 'path1', 'path1/path2', sdk会补齐末尾的 '/' |
| file_store_path          |       String       |  是   |       无       | 本地文件存储目录                                 |
| options                  |        Hash        |  否   |       无       |                                          |
| options[:disable_mkdir]  |      Boolean       |  否   |     true      | 禁止自动创建本地文件夹, 默认会创建                       |
| options[:min_slice_size] |      Integer       |  否   | 5 * 10 * 1024 | 完整下载最小文件大小,超过此大小将会使用分片多线程断点续传            |
| options[:download_retry] |      Integer       |  否   |      10       | 下载重试次数                                   |
| options[:disable_cpt]    |      Boolean       |  否   |     false     | 是否禁用checkpoint，如果禁用则不使用断点续传              |
| yield                    |       Float        |  否   |       无       | 下载进度百分比回调, 进度值是一个0-1之间的小数                |

注：不包含子目录。支持私有访问资源下载，SDK会自动携带鉴权签名。SDK会自动使用分片断点续传下载大文件。

返回：

``` ruby
Array<String> # 本地文件存储路径数组
```

示例：

``` ruby
files = bucket.download_all('path/', '~/test/path/') do |p|
  puts "下载进度: #{(p*100).round(2)}%")
end
puts files
```

#### 4.3.15 批量上传目录中的所有文件（upload_all）

``` ruby
@bucket.upload(path_or_dir, file_src_path, options = {}, &block)
```

参数：

| 参数名                          |         类型         |  必须  |       默认值        | 参数描述                                     |
| :--------------------------- | :----------------: | :--: | :--------------: | ---------------------------------------- |
| path_or_dir                  | String/COS::COSDir |  否   |        空         | 目录路径或目录对象COSDir目录路径如: '/', 'path1', 'path1/path2', sdk会补齐末尾的 '/' |
| file_src_path                |       String       |  是   |        无         | 本地文件夹路径                                  |
| options                      |        Hash        |  否   |        无         |                                          |
| options[:skip_error]         |      Boolean       |  否   |      false       | 是否跳过错误仍继续上传下一个文件                         |
| options[:auto_create_folder] |      Boolean       |  否   |      false       | 自动创建远端目录                                 |
| options[:min_slice_size]     |      Integer       |  否   | 10 * 1024 * 1024 | 完整上传最小文件大小,超过此大小将会使用分片多线程断点续传            |
| options[:upload_retry]       |      Integer       |  否   |        10        | 上传重试次数                                   |
| options[:biz_attr]           |       String       |  否   |        无         | 业务属性                                     |
| options[:disable_cpt]        |      Boolean       |  否   |      false       | 是否禁用checkpoint，如禁用仍可通过服务端进行断点续传          |
| options[:threads]            |      Integer       |  否   |        10        | 多线程上传线程数                                 |
| options[:slice_size]         |      Integer       |  否   | 3 * 1024 * 1024  | 设置分片上传时每个分片的大小。默认为3 MB, 目前服务端最大限制也为3MB。  |
| options[:cpt_file]           |       String       |  否   |        无         | 断点续传的checkpoint文件                        |
| yield                        |       Float        |  否   |        无         | 上传进度百分比回调, 进度值是一个0-1之间的小数                |

注：不包含子目录。SDK会自动使用分片断点续传上传大文件。

返回：

``` ruby
Array<COS::COSFile> # 详见目录操作（COS::COSFile）
```

示例：

``` ruby
files = @bucket.upload_all('/test', '~/path') do |pr|
  puts "上传进度 #{(pr*100).round(2)}%"
end
puts files
```

#### 4.3.16 获取资源个数详情（支持前缀搜索）（list_count）

``` ruby
@bucket.list_count(path = '', options = {})
```

参数：

| 参数名              |   类型   |  必须  | 默认值  | 参数描述                                     |
| :--------------- | :----: | :--: | :--: | ---------------------------------------- |
| path             | String |  否   |  空   | 目录路径, 如: 'path1', 'path1/path2', sdk会补齐末尾的 '/'。默认获取bucket根目录 |
| options          |  Hash  |      |      |                                          |
| options[:prefix] | String |  否   |  无   | 前缀搜索                                     |

返回：

``` ruby
Hash
{
  :total => 5, # 目录及文件总数
  :files => 2, # 文件总数
  :dirs => 3, # 目录总数
}
```

示例：

``` ruby
puts @bucket.list_count[:files]
```

#### 4.3.17 获取资源个数（count, size）

``` ruby
@bucket.count(path = '') # 别名 size
```

参数：

| 参数名  |   类型   |  必须  | 默认值  | 参数描述                                     |
| :--- | :----: | :--: | :--: | ---------------------------------------- |
| path | String |  否   |  空   | 目录路径, 如: 'path1', 'path1/path2', sdk会补齐末尾的 '/'。默认获取bucket根目录 |

返回：

``` ruby
Integer # 目录及文件总数
```

示例：

``` ruby
puts @bucket.count
```

#### 4.3.18 获取文件个数（count_files）

``` ruby
@bucket.count_files(path = '')
```

参数：

| 参数名  |   类型   |  必须  | 默认值  | 参数描述                                     |
| :--- | :----: | :--: | :--: | ---------------------------------------- |
| path | String |  否   |  空   | 目录路径, 如: 'path1', 'path1/path2', sdk会补齐末尾的 '/'。默认获取bucket根目录 |

返回：

``` ruby
Integer # 文件总数
```

示例：

``` ruby
puts @bucket.count_files
```

#### 4.3.19 获取目录个数（count_dirs）

``` ruby
@bucket.count_dirs(path = '')
```

参数：

| 参数名  |   类型   |  必须  | 默认值  | 参数描述                                     |
| :--- | :----: | :--: | :--: | ---------------------------------------- |
| path | String |  否   |  空   | 目录路径, 如: 'path1', 'path1/path2', sdk会补齐末尾的 '/'。默认获取bucket根目录 |

返回：

``` ruby
Integer # 目录总数
```

示例：

``` ruby
puts @bucket.count_dirs
```

### 4.4 资源操作

#### 4.4.1 文件操作（COS::COSFile）

##### 4.4.1.1 获取文件属性

``` ruby
# 文件名称 
puts file.name
# 文件格式化大小 1B 1KB 1.1MB 1.12GB...
puts file.format_size
```

| 属性                        | 类型      | 描述                          |
| ------------------------- | ------- | --------------------------- |
| name                      | String  | 名称                          |
| path                      | String  | 存储路径                        |
| ctime                     | String  | 创建时间unix时间戳                 |
| mtime                     | String  | 修改时间unix时间戳                 |
| created_at                | Time    | 创建时间Time                    |
| updated_at                | Time    | 修改时间Time                    |
| biz_attr                  | String  | 业务属性                        |
| filesize（file_size, size） | Integer | 文件大小                        |
| filelen                   | Integer | 已上传的文件大小                    |
| sha                       | String  | 文件sha1值                     |
| access_url                | String  | 文件访问url                     |
| type                      | String  | 类型，固定为file                  |
| format_size               | String  | 格式化文件大小 1B 1KB 1.1MB 1.12GB |

##### 4.4.1.2 获取当前文件属性（刷新）（stat）

``` ruby
file.stat
```

返回：

``` ruby
COS::COSFile
```

示例：

``` ruby
puts file.stat.to_hash
```

##### 4.4.1.3 更新当前文件属性（upadte）

``` ruby
file.update(biz_attr)
```

参数：

| 参数名      |   类型   |  必须  | 默认值  | 参数描述 |
| :------- | :----: | :--: | :--: | ---- |
| biz_attr | String |  是   |  无   | 业务属性 |

示例：

``` ruby
file.update('new biz attr')
```

##### 4.4.1.4 删除当前文件（delete）

``` ruby
file.delete
```

注意：删除失败将抛出异常

示例：

``` ruby
file.delete
```

##### 4.4.1.5 删除当前文件（无异常）（delete!）

``` ruby
file.delete!
```

注意：删除失败不会抛出异常，返回是否成功的bool值。

返回：

``` ruby
Boolean
```

示例：

``` ruby
puts file.delete!
```

##### 4.4.1.6 判断当前文件是否存在（exist?，exists?）

``` ruby
file.exist? # 别名 exists?
```

返回：

``` ruby
Boolean
```

示例：

``` ruby
puts file.exist?
```

##### 4.4.1.7 判断当前文件是否上传完成（complete?）

``` ruby
file.complete?
```

返回：

``` ruby
Boolean
```

示例：

``` ruby
puts file.complete?
```

##### 4.4.1.8 获取当前文件的访问URL（url）

``` ruby
file.url(options = {})
```

参数：

| 参数名                      |   类型    |  必须  |  默认值  | 参数描述                            |
| :----------------------- | :-----: | :--: | :---: | ------------------------------- |
| options                  |  Hash   |      |       |                                 |
| options[:cname]          | String  |  否   |   无   | 获取使用cname的url。在cos控制台设置的cname域名 |
| options[:https]          | Boolean |  否   | false | 是否获取https的url                   |
| options[:expire_seconds] | Integer |  否   |  600  | 签名有效时间(秒,私有读取bucket时需要)         |

返回：

``` ruby
String
```

示例：

``` ruby
puts file.url(https: true, cname: 'static.domain.com')
```

##### 4.4.1.9 下载当前文件（download）

``` ruby
file.download(file_store, options = {}, &block)
```

参数：

| 参数名                      |   类型    |  必须  |      默认值      | 参数描述                          |
| :----------------------- | :-----: | :--: | :-----------: | ----------------------------- |
| file_store               | String  |  是   |       无       | 本地文件存储路径                      |
| options                  |  Hash   |  否   |       无       |                               |
| options[:disable_mkdir]  | Boolean |  否   |     true      | 禁止自动创建本地文件夹, 默认会创建            |
| options[:min_slice_size] | Integer |  否   | 5 * 10 * 1024 | 完整下载最小文件大小,超过此大小将会使用分片多线程断点续传 |
| options[:download_retry] | Integer |  否   |      10       | 下载重试次数                        |
| options[:disable_cpt]    | Boolean |  否   |     false     | 是否禁用checkpoint，如果禁用则不使用断点续传   |
| yield                    |  Float  |  否   |       无       | 下载进度百分比回调, 进度值是一个0-1之间的小数     |

注：支持私有访问资源下载，SDK会自动携带鉴权签名。SDK会自动使用分片断点续传下载大文件。

返回：

``` ruby
String # 本地文件存储路径
```

示例：

``` ruby
file = file.download('~/test/file1') do |p|
  puts "下载进度: #{(p*100).round(2)}%")
end
puts file
```

##### 4.4.1.10 判断当前文件与本地文件是否相同

``` ruby
file.sha1_match?(file)
```

参数：

| 参数名  |   类型   |  必须  | 默认值  | 参数描述   |
| :--- | :----: | :--: | :--: | ------ |
| file | String |  是   |  无   | 本地文件路径 |

返回：

``` ruby
Boolean
```

示例：

``` ruby
puts file.sha1_match?('~/file1')
```



#### 4.4.2 目录操作（COS::COSDir）

##### 4.4.2.1 获取目录属性

``` ruby
# 目录名称 
puts dir.name
# 目录存储路径
puts dir.path
```

| 属性         | 类型     | 描述          |
| ---------- | ------ | ----------- |
| name       | String | 名称          |
| path       | String | 存储路径        |
| ctime      | String | 创建时间unix时间戳 |
| mtime      | String | 修改时间unix时间戳 |
| created_at | Time   | 创建时间Time    |
| updated_at | Time   | 修改时间Time    |
| biz_attr   | String | 业务属性        |
| type       | String | 类型，固定为dir   |

##### 4.4.2.2 列举当前目录（前缀搜索）（list，ls）

``` ruby
dir.list(options = {}) # 方法别名ls
```

参数：

| 参数名               |   类型    |  必须  |  默认值  | 参数描述                                     |
| :---------------- | :-----: | :--: | :---: | ---------------------------------------- |
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
dir.list do |res|
  if res.is_a?(COS::COSDir)
    puts "Dir: #{res.name} #{res.path}"
  else
    puts "File: #{res.name} #{res.format_size}"
  end
end
```

##### 4.4.2.3 创建子目录（create_folder，mkdir）

``` ruby
dir.create_folder(dir_name, options = {}) # 方法别名mkdir
```

参数：

| 参数名                |   类型   |  必须  | 默认值  | 参数描述                  |
| :----------------- | :----: | :--: | :--: | --------------------- |
| dir_name           | String |  是   |  无   | 需要创建的子目录名称，不包含父系目录路径。 |
| options            |  Hash  |      |      |                       |
| options[:biz_attr] | String |  否   |  无   | 目录属性, 业务端维护           |

返回：

``` ruby
COS::COSDir
```

示例：

``` ruby
dir.create_folder("test_dir2", biz_attr: '测试目录1-2')
```

##### 4.4.2.4 上传文件至当前目录（upload）

``` ruby
dir.upload(file_name, file_src, options = {}, &block)
```

参数：

| 参数名                          |   类型    |  必须  |       默认值        | 参数描述                                    |
| :--------------------------- | :-----: | :--: | :--------------: | --------------------------------------- |
| file_name                    | String  |  是   |        无         | 存储文件名                                   |
| file_src                     | String  |  是   |        无         | 本地文件路径                                  |
| options                      |  Hash   |  否   |        无         |                                         |
| options[:auto_create_folder] | Boolean |  否   |      false       | 自动创建远端目录                                |
| options[:min_slice_size]     | Integer |  否   | 10 * 1024 * 1024 | 完整上传最小文件大小,超过此大小将会使用分片多线程断点续传           |
| options[:upload_retry]       | Integer |  否   |        10        | 上传重试次数                                  |
| options[:biz_attr]           | String  |  否   |        无         | 业务属性                                    |
| options[:disable_cpt]        | Boolean |  否   |      false       | 是否禁用checkpoint，如禁用仍可通过服务端进行断点续传         |
| options[:threads]            | Integer |  否   |        10        | 多线程上传线程数                                |
| options[:slice_size]         | Integer |  否   | 3 * 1024 * 1024  | 设置分片上传时每个分片的大小。默认为3 MB, 目前服务端最大限制也为3MB。 |
| options[:cpt_file]           | String  |  否   |        无         | 断点续传的checkpoint文件                       |
| yield                        |  Float  |  否   |        无         | 上传进度百分比回调, 进度值是一个0-1之间的小数               |

注：SDK会自动使用分片断点续传上传大文件。

返回：

``` ruby
COS::COSFile
```

示例：

``` ruby
file = dir.upload('file1.txt', '~/test.txt') do |pr|
  puts "上传进度 #{(pr*100).round(2)}%"
end
puts file.name
puts file.format_size
puts file.url
```

##### 4.4.2.5 批量上传本地目录中的所有文件至当前目录（upload_all）

``` ruby
dir.upload(file_src_path, options = {}, &block)
```

参数：

| 参数名                          |   类型    |  必须  |       默认值        | 参数描述                                    |
| :--------------------------- | :-----: | :--: | :--------------: | --------------------------------------- |
| file_src_path                | String  |  是   |        无         | 本地文件夹路径                                 |
| options                      |  Hash   |  否   |        无         |                                         |
| options[:skip_error]         | Boolean |  否   |      false       | 是否跳过错误仍继续上传下一个文件                        |
| options[:auto_create_folder] | Boolean |  否   |      false       | 自动创建远端目录                                |
| options[:min_slice_size]     | Integer |  否   | 10 * 1024 * 1024 | 完整上传最小文件大小,超过此大小将会使用分片多线程断点续传           |
| options[:upload_retry]       | Integer |  否   |        10        | 上传重试次数                                  |
| options[:biz_attr]           | String  |  否   |        无         | 业务属性                                    |
| options[:disable_cpt]        | Boolean |  否   |      false       | 是否禁用checkpoint，如禁用仍可通过服务端进行断点续传         |
| options[:threads]            | Integer |  否   |        10        | 多线程上传线程数                                |
| options[:slice_size]         | Integer |  否   | 3 * 1024 * 1024  | 设置分片上传时每个分片的大小。默认为3 MB, 目前服务端最大限制也为3MB。 |
| options[:cpt_file]           | String  |  否   |        无         | 断点续传的checkpoint文件                       |
| yield                        |  Float  |  否   |        无         | 上传进度百分比回调, 进度值是一个0-1之间的小数               |

注：不包含子目录。SDK会自动使用分片断点续传上传大文件。

返回：

``` ruby
Array<COS::COSFile>
```

示例：

``` ruby
files = dir.upload_all('~/path') do |pr|
  puts "上传进度 #{(pr*100).round(2)}%"
end
```

##### 4.4.2.6 批量下载当前目录下的所有文件（download_all）

``` ruby
dir.download_all(file_store_path, options = {}, &block)
```

参数：

| 参数名                      |   类型    |  必须  |      默认值      | 参数描述                          |
| :----------------------- | :-----: | :--: | :-----------: | ----------------------------- |
| file_store_path          | String  |  是   |       无       | 本地文件存储目录                      |
| options                  |  Hash   |  否   |       无       |                               |
| options[:disable_mkdir]  | Boolean |  否   |     true      | 禁止自动创建本地文件夹, 默认会创建            |
| options[:min_slice_size] | Integer |  否   | 5 * 10 * 1024 | 完整下载最小文件大小,超过此大小将会使用分片多线程断点续传 |
| options[:download_retry] | Integer |  否   |      10       | 下载重试次数                        |
| options[:disable_cpt]    | Boolean |  否   |     false     | 是否禁用checkpoint，如果禁用则不使用断点续传   |
| yield                    |  Float  |  否   |       无       | 下载进度百分比回调, 进度值是一个0-1之间的小数     |

注：不包含子目录。支持私有访问资源下载，SDK会自动携带鉴权签名。SDK会自动使用分片断点续传下载大文件。

返回：

``` ruby
Array<String> # 本地文件存储路径数组
```

示例：

``` ruby
files = dir.download_all('~/test/path/') do |p|
  puts "下载进度: #{(p*100).round(2)}%")
end
```

##### 4.4.2.7 当前目录属性（刷新）（stat）

``` ruby
dir.stat
```

返回：

``` ruby
COS::COSDir
```

示例：

``` ruby
puts dir.stat.to_hash
```

##### 4.4.2.8 更新当前目录属性（upadte）

``` ruby
dir.update(biz_attr)
```

参数：

| 参数名      |   类型   |  必须  | 默认值  | 参数描述 |
| :------- | :----: | :--: | :--: | ---- |
| biz_attr | String |  是   |  无   | 业务属性 |

示例：

``` ruby
dir.update('new biz attr')
```

##### 4.4.2.9 删除当前目录（delete）

``` ruby
dir.delete
```

注意：非空目录或根目录无法删除，会抛出异常

示例：

``` ruby
dir.delete
```

##### 4.4.2.10 删除当前目录（无异常）（delete!）

``` ruby
dir.delete!
```

注意：非空目录或根目录无法删除，返回是否成功的bool值。

返回：

``` ruby
Boolean
```

示例：

``` ruby
puts dir.delete!
```

##### 4.4.2.11 判断当前目录是否为空（empty?）

``` ruby
dir.empty?
```

返回：

``` ruby
Boolean
```

示例：

``` ruby
puts dir.empty?
```

##### 4.4.2.12 判断当前目录是否存在（exist?，exists?）

``` ruby
dir.exist? # 别名 exists?
```

返回：

``` ruby
Boolean
```

示例：

``` ruby
puts dir.exist?
```

##### 4.4.2.13 获取当前目录下的Object树形结构（tree）

``` ruby
dir.tree(options = {})
```

参数：

| 参数名             |   类型    |  必须  | 默认值  | 参数描述       |
| :-------------- | :-----: | :--: | :--: | ---------- |
| options         |  Hash   |      |      |            |
| options[:depth] | Integer |  否   |  5   | 子目录深度,默认为5 |

返回：

``` 
{
    :resource => Object<COS::COSDir>,
    :children => [
    	{:resource => Object<COS::COSDir>, :children => [...]},
    	{:resource => Object<COS::COSFile>, :children => [...]},
    	...
    ]
}
```

示例：

``` ruby
tree = dir.tree
puts tree[:resource].name
tree[:children].each do |r|
  puts r[:resource].name
end
```

##### 4.4.2.14 获取当前目录下的Hash树形结构（hash_tree）

``` ruby
dir.hash_tree(options = {})
```

参数：

| 参数名             |   类型    |  必须  | 默认值  | 参数描述       |
| :-------------- | :-----: | :--: | :--: | ---------- |
| options         |  Hash   |      |      |            |
| options[:depth] | Integer |  否   |  5   | 子目录深度,默认为5 |

返回：

``` 
{
    :resource => {:name...},
    :children => [
    	{:resource => {:name...}, :children => [...]},
    	{:resource => {:name...}, :children => [...]},
    	...
    ]
}
```

示例：

``` ruby
tree = dir.hash_tree
puts tree[:resource][:name]
tree[:children].each do |r|
  puts r[:resource][:name]
end
puts tree.to_json # 可直接转为json
```

##### 4.4.2.15 获取当前目录下的资源个数详情（支持前缀搜索）（list_count）

``` ruby
dir.list_count(options = {})
```

参数：

| 参数名              |   类型   |  必须  | 默认值  | 参数描述 |
| :--------------- | :----: | :--: | :--: | ---- |
| options          |  Hash  |      |      |      |
| options[:prefix] | String |  否   |  无   | 前缀搜索 |

返回：

``` ruby
Hash
{
  :total => 5, # 目录及文件总数
  :files => 2, # 文件总数
  :dirs => 3, # 目录总数
}
```

示例：

``` ruby
puts dir.list_count[:files]
```

##### 4.4.2.16 获取当前目录下的资源个数（count, size）

``` ruby
dir.count # 别名 size
```

返回：

``` ruby
Integer # 目录及文件总数
```

示例：

``` ruby
puts dir.count
```

##### 4.4.2.17 获取当前目录下的文件个数（count_files）

``` ruby
dir.count_files
```

返回：

``` ruby
Integer # 文件总数
```

示例：

``` ruby
puts dir.count_files
```

##### 4.4.2.18 获取当前目录下的子目录个数（count_dirs）

``` ruby
dir.count_dirs
```

返回：

``` ruby
Integer # 目录总数
```

示例：

``` ruby
puts dir.count_dirs
```



### 4.5 签名操作（COS::Signature）

腾讯移动服务通过签名来验证请求的合法性。开发者通过将签名授权给客户端，使其具备上传下载及管理指定资源的能力。签名分为**多次有效签名**和**单次有效签名**

🔍具体适用场景参见[签名适用场景](http://www.qcloud.com/wiki/%E9%89%B4%E6%9D%83%E6%8A%80%E6%9C%AF%E6%9C%8D%E5%8A%A1%E6%96%B9%E6%A1%88#4_.E7.AD.BE.E5.90.8D.E9.80.82.E7.94.A8.E5.9C.BA.E6.99.AF)

#### 4.5.1 获取单次有效签名（once）

签名中绑定文件fileid，此签名只可使用一次，且只能应用于被绑定的文件。

``` ruby
puts @client.signature.once(bucket_name, path)
# path 为操作资源的路径
```



#### 4.5.2 获取多次有效签名（multiple）

签名中不绑定文件fileid，有效期内此签名可多次使用，有效期最长可设置三个月。

``` ruby
puts @client.signature.multiple(bucket_name, expire_seconds)
# expire_seconds 为从获取时间起得有效时间单位秒，必须大于0。
```



## 5 底层API（COS::API）

### 5.1 创建目录(create_folder)

``` ruby
@client.api.create_folder(path, options = {})
```

参数：

| 参数名                |   类型   |  必须  | 默认值  | 参数描述                                     |
| :----------------- | :----: | :--: | :--: | ---------------------------------------- |
| path               | String |  是   |  无   | 需要创建的目录路径, 如: 'path1', 'path1/path2', sdk会补齐末尾的 '/'。 |
| options            |  Hash  |      |      |                                          |
| options[:biz_attr] | String |  否   |  无   | 目录属性, 业务端维护                              |
| options[:bucket]   | String |  否   |  无   | bucket名称，如未配置default_bucket则必须制定         |

返回：

`Hash`

| 参数名           |   类型   |  必须  |    参数描述     |
| :------------ | :----: | :--: | :---------: |
| ctime         | String |  是   | 创建时间Unix时间戳 |
| resource_path | String |  是   |   创建的资源路径   |

示例：

``` ruby
puts @client.api.create_folder("test_dir5", biz_attr: '测试目录5')
```



### 5.2 目录列表（前缀搜索）(list)

``` ruby
@client.api.list(path, options = {})
```

参数：

| 参数名               |   类型    |  必须  |  默认值  | 参数描述                                     |
| :---------------- | :-----: | :--: | :---: | ---------------------------------------- |
| path              | String  |  是   |   否   | 需要列举的目录路径, 如: 'path1', 'path1/path2', sdk会补齐末尾的 '/'。 |
| options           |  Hash   |      |       |                                          |
| options[:prefix]  | String  |  否   |   无   | 搜索前缀，如果填写prefix, 则列出含此前缀的所有文件及目录         |
| options[:num]     | Integer |  否   |  20   |                                          |
| options[:pattern] | Symbol  |  否   | :both | 获取模式，:dir_only 只获取目录, :file_only 只获取文件, 默认为 :both 全部获取 |
| options[:order]   | Symbol  |  否   | :asc  | 排序方式 :asc 正序, :desc 倒序 默认为 :asc          |
| options[:context] | String  |  否   |   空   | 若需要翻页，需要将前一页返回值中的context透传到参数中           |
| options[:bucket]  | String  |  否   |   无   | bucket名称，如未配置default_bucket则必须制定         |

返回：

`Hash`

| 参数名             |     类型      |  必须  |                   参数描述                   |
| :-------------- | :---------: | :--: | :--------------------------------------: |
| context         |   String    |  是   |         透传字段,用于翻页,需要往前/往后翻页则透传回来         |
| has_more        |   Boolean   |  是   |             是否有内容可以继续往前/往后翻页             |
| dircount        |   Integer   |  是   |                 子目录数量(总)                 |
| filecount       |   Integer   |  是   |                 子文件数量(总)                 |
| infos           | Array<Hash> |  是   |                列表结果(可能为空)                |
| 子属性 :name       |   String    |  是   |                 目录名/文件名                  |
| 子属性 :biz_attr   |   String    |  是   |              目录/文件属性，业务端维护               |
| 子属性 :filesize   |   Integer   |  否   |             文件大小(当类型为文件时返回)              |
| 子属性 :filelen    |   Integer   |  否   | 文件已传输大小(通过与filesize对比可知文件传输进度,当类型为文件时返回) |
| 子属性 :sha        |   String    |  否   |            文件sha1(当类型为文件时返回)             |
| 子属性 :ctime      |   String    |  是   |              创建时间(Unix时间戳)               |
| 子属性 :mtime      |   String    |  是   |              修改时间(Unix时间戳)               |
| 子属性 :access_url |   String    |  否   |         生成的资源可访问的url(当类型为文件时返回)          |

示例：

``` ruby
puts @client.api.list('/test', pattern: :dir_only, order: :desc, prefix: 'abc', context: '')
```



### 5.3 上传文件（完整上传）(upload)

``` ruby
@client.api.upload(path, file_name, file_src, options = {})
```

参数：

| 参数名                |   类型   |  必须  | 默认值  | 参数描述                                     |
| :----------------- | :----: | :--: | :--: | ---------------------------------------- |
| path               | String |  是   |  无   | 目录路径, 如: '/', 'path1', 'path1/path2', sdk会补齐末尾的 '/' |
| file_name          | String |  是   |  无   | 存储文件名                                    |
| file_src           | String |  是   |  无   | 本地文件路径                                   |
| options            |  Hash  |  否   |  无   |                                          |
| options[:biz_attr] | String |  否   |  无   | 文件属性, 业务端维护                              |
| options[:bucket]   | String |  否   |  无   | bucket名称，如未配置default_bucket则必须制定         |

返回：

`Hash`

| 参数名           |   类型   |  必须  |    参数描述    |
| :------------ | :----: | :--: | :--------: |
| access_url    | String |  是   | 生成的文件下载url |
| url           | String |  是   |  操作文件的url  |
| resource_path | String |  是   |    资源路径    |

示例：

``` ruby
puts @client.api.upload('/test', 'file1.txt', '~/test.txt')
```



### 5.4 上传文件（分片上传）(upload_slice)

``` ruby
@client.api.upload_slice(path, file_name, file_src, options = {})
```

参数：

| 参数名                   |   类型    |  必须  |       默认值       | 参数描述                                     |
| :-------------------- | :-----: | :--: | :-------------: | ---------------------------------------- |
| path                  | String  |  是   |        无        | 目录路径, 如: '/', 'path1', 'path1/path2', sdk会补齐末尾的 '/' |
| file_name             | String  |  是   |        无        | 存储文件名                                    |
| file_src              | String  |  是   |        无        | 本地文件路径                                   |
| options               |  Hash   |  否   |        无        |                                          |
| options[:biz_attr]    | String  |  否   |        无        | 业务属性                                     |
| options[:disable_cpt] | Boolean |  否   |      false      | 是否禁用checkpoint，如禁用仍可通过服务端进行断点续传          |
| options[:threads]     | Integer |  否   |       10        | 多线程上传线程数                                 |
| options[:slice_size]  | Integer |  否   | 3 * 1024 * 1024 | 设置分片上传时每个分片的大小。默认为3 MB, 目前服务端最大限制也为3MB。  |
| options[:cpt_file]    | String  |  否   |        无        | 断点续传的checkpoint文件                        |
| options[:bucket]      | String  |  否   |        无        | bucket名称，如未配置default_bucket则必须制定         |
| yield                 |  Float  |  否   |        无        | 上传进度百分比回调, 进度值是一个0-1之间的小数                |

返回：

`Hash`

| 参数名           |   类型   |  必须  |    参数描述    |
| :------------ | :----: | :--: | :--------: |
| access_url    | String |  是   | 生成的文件下载url |
| url           | String |  是   |  操作文件的url  |
| resource_path | String |  是   |    资源路径    |

示例：

``` ruby
puts @client.api.upload_slice('/test', 'file1.txt', '~/test.txt') do |pr|
  puts "上传进度 #{(pr*100).round(2)}%"
end
```



### 5.5 更新文件、目录属性(update)

``` ruby
@client.api.update(path, biz_attr, options = {})
```

参数：

| 参数名              |   类型   |  必须  | 默认值  | 参数描述                                     |
| :--------------- | :----: | :--: | :--: | ---------------------------------------- |
| path             | String |  是   |  无   | 需要创建的目录路径, 如: 'path1', 'path1/path2', sdk会补齐末尾的 '/'。 |
| biz_attr         | String |  是   |  无   | 目录属性, 业务端维护                              |
| options          |  Hash  |      |      |                                          |
| options[:bucket] | String |  否   |  无   | bucket名称，如未配置default_bucket则必须制定         |

返回：无

示例：

``` ruby
@client.api.update('test/file1', 'new biz attr')
```

### 5.6 删除文件、目录(delete)

``` ruby
@client.api.delete(path, options = {})
```

参数：

| 参数名              |   类型   |  必须  | 默认值  | 参数描述                                     |
| :--------------- | :----: | :--: | :--: | ---------------------------------------- |
| path             | String |  是   |  无   | 需要创建的目录路径, 如: 'path1', 'path1/path2', sdk会补齐末尾的 '/'。 |
| options          |  Hash  |      |      |                                          |
| options[:bucket] | String |  否   |  无   | bucket名称，如未配置default_bucket则必须制定         |

返回：无

示例：

``` ruby
@client.api.delete('test/file1')
```

### 5.7 获取文件或目录属性(stat)

``` ruby
@client.api.update(path, options = {})
```

参数：

|                  |   类型   |  必须  | 默认值  | 参数描述                                     |
| :--------------- | :----: | :--: | :--: | ---------------------------------------- |
| path             | String |  是   |  无   | 需要创建的目录路径, 如: 'path1', 'path1/path2', sdk会补齐末尾的 '/'。 |
| options          |  Hash  |      |      |                                          |
| options[:bucket] | String |  否   |  无   | bucket名称，如未配置default_bucket则必须制定         |

返回：

`Hash`

| 参数名        |   类型    |  必须  |                   参数描述                   |
| :--------- | :-----: | :--: | :--------------------------------------: |
| name       | String  |  是   |                 目录名/文件名                  |
| biz_attr   | String  |  是   |              目录/文件属性，业务端维护               |
| filesize   | Integer |  否   |             文件大小(当类型为文件时返回)              |
| filelen    | Integer |  否   | 文件已传输大小(通过与filesize对比可知文件传输进度,当类型为文件时返回) |
| sha        | String  |  否   |            文件sha1(当类型为文件时返回)             |
| ctime      | String  |  是   |              创建时间(Unix时间戳)               |
| mtime      | String  |  是   |              修改时间(Unix时间戳)               |
| access_url | String  |  否   |         生成的资源可访问的url(当类型为文件时返回)          |

示例：

``` ruby
puts @client.api.stat('/test/file')
```

### 5.8下载文件

``` ruby
@client.api.download(access_url, file_store, options = {})
```

参数：

| 参数名               |   类型   |  必须  | 默认值  | 参数描述                             |
| :---------------- | :----: | :--: | :--: | -------------------------------- |
| access_url        | String |  是   |  无   | 资源的下载URL地址可以从list,stat接口中获取      |
| file_store        | String |  是   |  无   | 本地文件存储路径                         |
| options           |  Hash  |  否   |  无   |                                  |
| options[:bucket]  | String |  否   |  无   | bucket名称，如未配置default_bucket则必须制定 |
| options[:headers] |  Hash  |  否   |  无   | 设置下载请求头,如:rang                   |

示例：

``` ruby
@client.api.download('/test/file', '~/test.txt')
```



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
  cos is_exist [PATH]                        # 判断文件或目录是否存在
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