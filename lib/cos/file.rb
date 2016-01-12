# coding: utf-8

module COS

  # COS文件资源
  class COSFile < ResourceOperator

    STORAGE_UNITS = %w[B KB MB GB]
    STORAGE_BASE = 1024

    def initialize(attrs = {})
      super(attrs)
      @type = 'file'
    end

    def filesize
      @filesize.to_i
    end

    def filelen
      @filelen.to_i
    end

    # 文件sha1是否一致
    def sha1_match?(file)
      File.exist?(file) and sha.upcase == Util.file_sha1(file).upcase
    end

    # 文件大小
    def size
      filesize.to_i
    end

    # 格式化文件大小 1B 1KB 1.1MB 1.12GB...
    def format_size
      if filesize.to_i < STORAGE_BASE
        size_str = filesize.to_s + STORAGE_UNITS[0]
      else
        c_size = human_rep(filesize.to_i)
        size_str = "%.2f" % c_size[:size].round(2)
        size_str = "#{size_str}#{c_size[:unit]}"
      end

      size_str
    end

    # 文件是否完整, 是否上传完了
    def complete?
      access_url != nil and filelen == filesize
    end

    # 文件URL, 支持cname,https
    def url(options = {})
      bucket.url(path, options)
    end

    # 下载文件
    def download(file_store, options = {}, &block)
      bucket.download(self, file_store, options, &block)
    end

    private

    # 计算文件大小格式化单位
    def human_rep(bytes)
      number   = Float(bytes)
      max_exp  = STORAGE_UNITS.size - 1

      exponent = (Math.log(bytes) / Math.log(STORAGE_BASE)).to_i
      exponent = max_exp if exponent > max_exp

      number   /= STORAGE_BASE ** exponent
      unit     = STORAGE_UNITS[exponent]

      { size: number, unit: unit }
    end

  end

end