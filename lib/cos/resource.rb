# coding: utf-8

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

      # 遍历结果转换为对应的对象
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
      return if @more[:has_more] == false
      fetch
    end

  end

  class ResourceOperator < Struct::Base

    required_attrs :bucket, :path, :name, :ctime, :mtime
    optional_attrs :biz_attr, :filesize, :filelen, :sha, :access_url,
                   # 根目录参数
                   :authority, :bucket_type, :migrate_source_domain,
                   :need_preview, :refers

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
      hash = {
          type:   type,
          bucket: bucket.bucket_name,
          path:   path,
          name:   name,
          ctime:  ctime,
          mtime:  mtime,
      }

      optional_attrs.each do |key|
        hash[key] = send(key.to_s) if respond_to?(key) and send(key.to_s) != nil
      end

      hash
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
      self
    end

    # 删除文件或目录, 不会抛出异常而是返回布尔值
    def delete!
      bucket.delete!(path)
    end

  end

end