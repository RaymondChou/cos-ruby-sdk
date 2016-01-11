# coding: utf-8

module COS

  class Tree < Struct::Base

    MAX_DEPTH = 5

    required_attrs :path
    optional_attrs :depth, :files_count, :files

    def initialize(options = {})
      super(options)
      @tree_str = ''
      @depth    = depth || MAX_DEPTH
    end

    # 输出Object格式, 可以直接用于链式调用
    # @example
    # {
    #   :resource => resource,
    #   :children => [
    #     {:resource => resource, :children => [...]},
    #     {:resource => resource, :children => [...]},
    #     ...
    #   ]
    # }
    def to_object
      create_tree(path, [], :object)
    end

    # 输出Hash格式, 可以直接.to_json转化为json string
    # @example
    # {
    #   :resource => {name: '', mtime: ''...},
    #   :children => [
    #     {:resource => resource, :children => [...]},
    #     {:resource => resource, :children => [...]},
    #     ...
    #   ]
    # }
    def to_hash
      create_tree(path, [], :hash)
    end

    # 命令行打印树结构
    def print_tree
      create_tree(path, [])
      puts @tree_str
    end

    private

    # 递归创建树
    def create_tree(dir, level, type = nil)
      @tree_str << row_string_for_dir(dir, level) if type.nil?
      children = []

      if level.count < depth and dir.is_a?(COS::COSDir)
        cd = child_directories(dir)

        i = 0
        while i < cd.count  do
          level_dup = level.dup
          is_last = i + 1 == cd.count
          la = level_dup << is_last

          ct = create_tree(cd[i], la, type)
          children << ct if type != nil
          i += 1
        end
      end

      if type != nil
        if type == :hash
          resource = dir.to_hash
        else
          resource = dir
        end
        {resource: resource, children: children}
      end
    end

    # 获取子目录结构
    def child_directories(dir)
      dirs = []

      pattern = @files ? :both : :dir_only

      dir.list(pattern: pattern).each do |d|
        if d.is_a?(COS::COSDir)
          dirs << d
        else
          dirs << d if @files
        end
      end

      dirs
    end

    # 打印输出目录行
    def row_string_for_dir(dir, level)
      if dir.name == ''
        # 根目录显示Bucket
        dirname = "Bucket #{dir.bucket.bucket_name}"
      else

        if dir.is_a?(COS::COSDir)
          dirname = "#{dir.name}"

          if @files_count
            counts = dir.count_files
            dirname << " \033[32m(#{counts})\033[0m" if counts > 0
          end

        else
          dirname = "\033[34m#{dir.name}\033[0m"
          dirname << " \033[31m(#{dir.format_size})\033[0m"
        end
      end

      dirname << " \033[35m[#{dir.biz_attr}]\033[0m" if dir.biz_attr != ''

      row_str = ''
      row_str << level_header_for_row(level)
      row_str << dirname
      row_str << "\n"
    end

    # 打印输出层级关系
    def level_header_for_row(level)
      header_str = "\033[33m"
      lc = level.count
      if lc > 0
        i = 0

        while i < lc
          if i + 1 == lc

            if level[i]
              header_str << "└── "
            else
              header_str << "├── "
            end

          else

            if level[i]
              header_str << "    "
            else
              header_str << "│   "
            end

          end
          i += 1
        end

      end
      header_str << "\033[0m"
      header_str
    end

  end

end