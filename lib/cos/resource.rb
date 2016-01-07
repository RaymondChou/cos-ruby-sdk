module COS

  class Resource

    attr_reader :bucket, :path, :dir_count, :file_count

    def initialize(bucket, path, options = {})
      @bucket      = bucket
      @path        = path
      @more        = options
      @results     = Array.new
      @dir_count   = 0
      @file_count  = 0
    end

    # 实现迭代器
    def next
      loop do
        # 从接口获取下一页结果
        fetch_more if @results.empty?

        # 取出结果
        r = @results.shift
        break unless r

        yield r
      end
    end

    # 返回迭代器
    def to_enum
      self.enum_for(:next)
    end

    # 获取列表
    def fetch
      client = bucket.client
      resp = client.api.list(path, @more.merge({bucket: bucket.bucket_name}))

      @results = resp[:infos].map do |r|
        if r[:filesize].nil?
          # 目录
          COSDir.new(r.merge({
                                 bucket: bucket,
                                 path: Util.get_list_path(path, r[:name])
                             }))
        else
          # 文件
          COSFile.new(r.merge({
                                  bucket: bucket,
                                  path: Util.get_list_path(path, r[:name], true)
                              }))
        end
      end || []

      @dir_count  = resp[:dir_count]
      @file_count = resp[:file_count]

      @more[:context]  = resp[:context]
      @more[:has_more] = resp[:has_more]
    end

    private

    # 如果有更多页继续获取下一页
    def fetch_more
      return if @more[:has_more] === false
      fetch
    end

  end

  class ResourceOperator < Struct::Base

    required_attrs :bucket, :path, :name, :ctime, :mtime
    optional_attrs :biz_attr, :filesize, :filelen, :sha, :access_url

    attr_reader :type

    alias :file_size :filesize
    alias :file_len :filelen

    def initialize(attrs)
      super(attrs)
    end

    # 创建时间Time类型
    def created_at
      Time.at(ctime.to_i)
    end

    # 更新时间Time类型
    def updated_at
      Time.at(mtime.to_i)
    end

    # 参数转化为Hash类型
    def to_hash
      {
          bucket:     bucket.bucket_name,
          path:       path,
          name:       name,
          ctime:      ctime,
          mtime:      mtime,
          biz_attr:   respond_to?(:biz_attr) ? biz_attr : nil,
          filesize:   respond_to?(:filesize) ? filesize.to_i : nil,
          filelen:    respond_to?(:filelen) ? filelen.to_i : nil,
          sha:        respond_to?(:sha) ? sha : nil,
          access_url: respond_to?(:access_url) ? access_url : nil
      }
    end

    # 文件或目录是否存在
    def exist?
      bucket.exist?(path)
    end

    alias :exists? :exist?

    # 文件或目录的状态
    def stat
      bucket.stat(path)
    end

    # 更新文件或目录的属性
    def update(biz_attr)
      bucket.update(path, biz_attr)
      @mtime    = Time.now.to_i.to_s
      @biz_attr = biz_attr
      self
    end

    # 删除文件或目录
    def delete
      bucket.delete(path)
    end

  end

  # COS文件资源
  class COSFile < ResourceOperator

    def initialize(attrs = {})
      super(attrs)
      @type = 'file'
    end

    # 文件是否完整, 是否上传完了
    def complete?
      filelen == filesize
    end

    # 文件URL, 支持cname,https
    def url(options = {})
      bucket.url(path, options)
    end

    # 下载文件
    def download(file_store, options = {}, &block)
      bucket.download(self, file_store, options, &block)
    end

  end

  # COS目录资源
  class COSDir < ResourceOperator

    def initialize(attrs = {})
      super(attrs)
      @type = 'dir'
    end

    # 上传文件,自动判断使用分片上传,断点续传及自动重试,多线程上传
    def upload(file_name, file_src, options = {}, &block)
      bucket.upload(path, file_name, file_src, options, &block)
    end

    # 列出目录
    def list(options = {})
      bucket.list(path, options)
    end

    alias :ls :list

    # 创建目录
    def create_folder(dir_name, options = {})
      bucket.create_folder("#{path}#{dir_name}", options)
    end

    alias :mkdir :create_folder

    # 获取文件或目录总数信息
    def list_count(options = {})
      bucket.list_count(path, options)
    end

    # 获取文件及目录总数
    def count(options = {})
      bucket.count(path, options)
    end

    alias :size :count

  end

end