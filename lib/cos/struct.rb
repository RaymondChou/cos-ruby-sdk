module COS

    module Struct
      class Base
        module AttrHelper

          # 动态创建必选参数
          def required_attrs(*s)
            define_method(:required_attrs) {s}
            attr_reader(*s)
          end

          # 动态创建可选参数
          def optional_attrs(*s)
            define_method(:optional_attrs) {s}
            attr_reader(*s)
          end
        end

        extend AttrHelper

        def initialize(options = {})
          # 意外参数检测
          extra_keys = options.keys - required_attrs - optional_attrs
          unless extra_keys.empty?
            raise AttrError, "Unexpected extra keys: #{extra_keys.join(', ')}"
          end

          # 必选参数检测
          required_keys = required_attrs - options.keys
          unless required_keys.empty?
            raise AttrError, "Keys: #{required_keys.join(', ')} is Required"
          end

          # 动态创建实例变量
          (required_attrs + optional_attrs).each do |attr|
            instance_variable_set("@#{attr}", options[attr])
          end
        end

      end
    end

end

