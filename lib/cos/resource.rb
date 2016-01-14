# coding: utf-8

module COS

  class Resource

    attr_reader :bucket, :path, :dir_count, :file_count

    # 实例化COS资源迭代器
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

  # COS资源,文件与目录的共有操作
  class ResourceOperator < Struct::Base

    required_attrs :bucket, :path, :name, :ctime, :mtime
    optional_attrs :biz_attr, :filesize, :filelen, :sha, :access_url,
                   # 根目录(bucket)参数
                   :authority, :bucket_type, :migrate_source_domain,
                   :need_preview, :refers, :blackrefers, :brower_exec,
                   :cnames, :nugc_flag, :SKIP_EXTRA

    # 资源类型
    attr_reader :type

    alias :file_size :filesize
    alias :file_len :filelen

    def initialize(attrs)
      super(attrs)
    end

    # 创建时间Time类型
    #
    # @return [Time]
    def created_at
      Time.at(ctime.to_i)
    end

    # 更新时间Time类型
    #
    # @return [Time]
    def updated_at
      Time.at(mtime.to_i)
    end

    # 参数转化为Hash类型
    #
    # @return [Hash]
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

    # 判断当前资源是否存在
    #
    # @raise [ServerError] 服务端异常返回
    #
    # @return [Boolean] 是否存在
    #
    # @example
    #   puts resource.exist?
    def exist?
      bucket.exist?(path)
    end

    alias :exists? :exist?

    # 获取(刷新)当前资源的状态
    #
    # @note 如查询根目录('/', '')可以获取到bucket信息, 返回COSDir
    #
    # @raise [ServerError] 服务端异常返回
    #
    # @return [COSFile|COSDir] 如果是目录则返回COSDir资源对象,是文件则返回COSFile资源对象
    #
    # @example
    #   puts resource.stat.name
    def stat
      bucket.stat(path)
    end

    # 更新当前资源的属性
    #
    # @note 根目录('/') 不可更新, 否则会抛出异常
    #
    # @param biz_attr [String] 目录/文件属性，业务端维护
    #
    # @raise [ServerError] 服务端异常返回
    #
    # @example
    #   resource.update('i am the attr')
    def update(biz_attr)
      bucket.update(path, biz_attr)
      @mtime    = Time.now.to_i.to_s
      @biz_attr = biz_attr
      self
    end

    # 删除当前资源
    #
    # @note 非空目录及根目录不可删除,会抛出异常
    #
    # @raise [ServerError] 服务端异常返回
    #
    # @example
    #   resource.delete
    def delete
      bucket.delete(path)
      self
    end

    # 删除当前资源, 不会抛出异常而是返回布尔值
    #
    # @note 非空目录及根目录不可删除, 返回false
    #
    # @example
    #   puts resource.delete!
    def delete!
      bucket.delete!(path)
    end

  end

end