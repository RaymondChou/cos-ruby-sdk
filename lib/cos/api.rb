require 'json'

module COS

  class API

    attr_reader :config, :http

    def initialize(config)
      @config = config
      @http   = COS::HTTP.new(config)
    end

    # 创建目录
    # @param path [String] 目录路径,
    #  如: 'path1', 'path1/path2', sdk会补齐末尾的 '/'
    # @param options [Hash] 高级参数
    # @option options [String] :biz_attr 目录属性, 业务端维护
    # @option options [String] :bucket bucket名称
    # @return Hash
    #  * :ctime [String] 创建时间Unix时间戳
    #  * :resource_path [String] 创建的资源路径
    def create_folder(path, options = {})
      bucket  = config.get_bucket(options[:bucket])
      sign    = http.signature.multiple(bucket)
      payload = {op: 'create', biz_attr: options[:biz_attr]}
      resource_path = Util.get_resource_path(config.app_id, bucket, path)

      http.post(resource_path, {}, sign, payload.to_json)
    end

    # 上传文件(完整上传)
    # @param path [String] 目录路径,
    #  如: '/', 'path1', 'path1/path2', sdk会补齐末尾的 '/'
    # @param file_name [String] 文件名
    # @param file_src [String] 本地文件路径
    # @param options [Hash] 高级参数
    # @option options [String] :biz_attr 目录属性, 业务端维护
    # @option options [String] :bucket bucket名称
    # @return Hash
    #  * :access_url [String] 生成的文件下载url
    #  * :url [String] 操作文件的url
    #  * :resource_path [String] 资源路径
    def upload(path, file_name, file_src, options = {})
      bucket        = config.get_bucket(options[:bucket])
      sign          = http.signature.multiple(bucket)
      resource_path = Util.get_resource_path(config.app_id, bucket, path, file_name)

      payload = {
          op:            'upload',
          sha:           Util.file_sha1(file_src),
          filecontent:   File.new(file_src, 'rb'),
          biz_attr:      options[:biz_attr]
      }

      http.post(resource_path, {}, sign, payload)
    end

    # 上传文件(分片上传)
    # @param path [String] 目录路径,
    #  如: '/', 'path1', 'path1/path2', sdk会补齐末尾的 '/'
    # @param file_name [String] 文件名
    # @param file_src [String] 本地文件路径
    # @param options [Hash] 高级参数
    # @option options [String] :biz_attr 目录属性, 业务端维护
    # @option options [String] :bucket bucket名称
    # @option options [Boolean] :disable_cpt 是否禁用checkpoint功能，如
    #  果设置为true，则在上传的过程中不会写checkpoint文件，这意味着
    #  上传失败后不能断点续传，而只能重新上传整个文件。如果这个值为
    #  true，则:cpt_file会被忽略。
    # @option options [Integer] :threads 多线程上传线程数, 默认为10
    # @option options [Integer] :slice_size 设置分片上传时每个分片的大小
    #  默认为3 MB, 目前服务端最大限制也为3MB。
    # @option options [String] :cpt_file 断点续传的checkpoint文件，如果
    #  指定的cpt文件不存在，则会在file所在目录创建一个默认的cpt文件，
    #  命名方式为：file.cpt，其中file是用户要下载的文件名。在下载的过
    #  程中会不断更新此文件，成功完成下载后会删除此文件；如果指定的
    #  cpt文件已存在，则从cpt文件中记录的点继续下载。
    # @yield [Float] 上传进度百分比回调, 进度值是一个0-1之间的小数
    # @return Hash
    #  * :access_url [String] 生成的文件下载url
    #  * :url [String] 操作文件的url
    #  * :resource_path [String] 资源路径
    def upload_slice(path, file_name, file_src, options = {}, &block)
      slice = Slice.new(
          config:    config,
          http:      http,
          path:      path,
          file_name: file_name,
          file_src:  file_src,
          options:   options,
          progress:  block
      ).upload

      {
          access_url:    slice[:access_url],
          url:           slice[:url],
          resource_path: slice[:resource_path]
      }
    end

    # 目录列表/前缀搜索
    # @param path [String] 目录路径,
    #  如: '/', 'path1', 'path1/path2', sdk会补齐末尾的 '/'
    #  如果填写prefix, 则列出含此前缀的所有文件及目录
    # @param options [Hash]
    # @option options [String] :bucket bucket名称
    # @option options [String] :prefix 搜索前缀
    # @option options [Integer] :num 每页拉取的数量, 默认20条
    # @option options [Symbol] :pattern 获取方式
    #  :dir_only 只获取目录, :file_only 只获取文件, 默认为 :both 全部获取
    # @option options [Symbol] :order 排序方式
    #  :asc 正序, :desc 倒序 默认为 :asc
    # @option options [String] :context 页码
    #  若需要翻页，需要将前一页返回值中的context透传到参数中
    #  若order为:asc，则从当前页正序/往下翻页；若order为:desc，则从当前页倒序/往上翻
    # @return Hash
    #  * :context [String] 透传字段,用于翻页,需要往前/往后翻页则透传回来
    #  * :has_more [Boolean] 是否有内容可以继续往前/往后翻页
    #  * :dircount [Integer] 子目录数量(总)
    #  * :filecount [Integer] 子文件数量(总)
    #  * :filecount [Integer] 子文件数量(总)
    #  * :infos [Array<Hash>] 列表结果(可能为空)
    #  *  * :name [String] 目录名/文件名
    #  *  * :biz_attr [String] 目录/文件属性，业务端维护
    #  *  * :filesize [Integer] 文件大小(当类型为文件时返回)
    #  *  * :filelen [Integer] 文件已传输大小(通过与filesize对比可知文件传输进度,当类型为文件时返回)
    #  *  * :sha [String] 文件sha1(当类型为文件时返回)
    #  *  * :ctime [String] 创建时间(Unix时间戳)
    #  *  * :mtime [String] 修改时间(Unix时间戳)
    #  *  * :access_url [String] 生成的资源可访问的url(当类型为文件时返回)
    def list(path, options = {})
      bucket  = config.get_bucket(options[:bucket])
      sign    = http.signature.multiple(bucket)
      resource_path = Util.get_resource_path(config.app_id, bucket, path, options[:prefix])

      pattern = case options[:pattern]
                  when :dir_only
                    'eListDirOnly'
                  when :file_only
                    'eListFileOnly'
                  else
                    'eListBoth'
                end

      query = {
          op:       'list',
          num:      options[:num] || 20,
          pattern:  pattern,
          order:    options[:order] == :desc ? 1 : 0,
          context:  options[:context]
      }

      http.get(resource_path, {params: query}, sign)
    end

    # 更新目录/文件信息(biz_attr)
    # @param path [String] 资源路径,
    #  如: 目录'path1/', 文件'path1/file'
    # @param biz_attr [String] 目录/文件属性，业务端维护
    # @param options [Hash]
    # @option options [String] :bucket bucket名称
    def update(path, biz_attr, options = {})
      bucket        = config.get_bucket(options[:bucket])
      resource_path = Util.get_resource_path_or_file(config.app_id, bucket, path)
      sign          = http.signature.once(bucket, path)
      payload       = {op: 'update', biz_attr: biz_attr}

      http.post(resource_path, {}, sign, payload.to_json)
    end

    # 目录/文件信息查询
    # @param path [String] 资源路径,
    #  如: 目录'path1/', 文件'path1/file'
    # @param options [Hash]
    # @option options [String] :bucket bucket名称
    # @return Hash
    #  * :name [String] 目录名/文件名
    #  * :biz_attr [String] 目录/文件属性，业务端维护
    #  * :filesize [Integer] 文件大小(当类型为文件时返回)
    #  * :filelen [Integer] 文件已传输大小(通过与filesize对比可知文件传输进度,当类型为文件时返回)
    #  * :sha [String] 文件sha1(当类型为文件时返回)
    #  * :ctime [String] 创建时间(Unix时间戳)
    #  * :mtime [String] 修改时间(Unix时间戳)
    #  * :access_url [String] 生成的资源可访问的url(当类型为文件时返回)
    def stat(path, options = {})
      bucket        = config.get_bucket(options[:bucket])
      sign          = http.signature.multiple(bucket)
      resource_path = Util.get_resource_path_or_file(config.app_id, bucket, path)

      http.get(resource_path, {params: {op: 'stat'}}, sign)
    end

    # 删除文件及目录
    # @param path [String] 资源路径,
    #  如: 目录'path1/', 文件'path1/file'
    # @param options [Hash]
    # @option options [String] :bucket bucket名称
    def delete(path, options = {})
      bucket        = config.get_bucket(options[:bucket])
      resource_path = Util.get_resource_path_or_file(config.app_id, bucket, path)
      sign          = http.signature.once(bucket, path)
      payload       = {op: 'delete'}

      http.post(resource_path, {}, sign, payload.to_json)
    end

  end

end