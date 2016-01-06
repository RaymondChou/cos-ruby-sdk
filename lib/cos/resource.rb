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

    def to_enum
      self.enum_for(:next)
    end

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

    def created_at
      Time.at(ctime.to_i)
    end

    def updated_at
      Time.at(mtime.to_i)
    end

    def to_hash
      {
          bucket:     bucket,
          path:       path,
          name:       name,
          ctime:      ctime,
          mtime:      mtime,
          biz_attr:   respond_to?(:biz_attr) ? biz_attr : nil,
          filesize:   respond_to?(:filesize) ? filesize : nil,
          filelen:    respond_to?(:filelen) ? filelen : nil,
          sha:        respond_to?(:sha) ? sha : nil,
          access_url: respond_to?(:access_url) ? access_url : nil
      }
    end

    def exist?
      bucket.exist?(path)
    end

    alias :exists? :exist?

    def stat
      bucket.stat(path)
    end

    def update(biz_attr)
      bucket.update(path, biz_attr)
      @mtime    = Time.now.to_i.to_s
      @biz_attr = biz_attr
      self
    end

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

    def complete?
      filelen == filesize
    end

  end

  # COS目录资源
  class COSDir < ResourceOperator

    def initialize(attrs = {})
      super(attrs)
      @type = 'dir'
    end

    def upload(file_name, file_src, options = {}, &block)
      bucket.upload(path, file_name, file_src, options, &block)
    end

    def list(options = {})
      bucket.list(path, options)
    end

    alias :ls :list

    def create_folder(dir_name, options = {})
      bucket.create_folder("#{path}#{dir_name}", options)
    end

    alias :mkdir :create_folder

    def list_count(options = {})
      bucket.list_count(path, options)
    end

    def count(options = {})
      bucket.count(path, options)
    end

    alias :size :count

  end

end