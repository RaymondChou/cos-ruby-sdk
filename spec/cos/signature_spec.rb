require 'spec_helper'
require 'minitest/mock'

module COS

  describe Signature do

    before :all do
      @config = Config.new({
                               app_id: '100000',
                               secret_id: 'secret_id',
                               secret_key: 'secret_key'
                           })

      Signature.send(:public, *Signature.private_instance_methods)
    end

    # 测试签名字符串是否正确
    it 'should get correct string_to_sign' do
      Time.stub :now, Time.at(0) do
        s = Signature.new(@config)

        s.instance_variable_set(:@file_id, '/file/id')

        s.stub(:rand, 8888) do
          expect(
              s.string_to_sign(:once, 'bucket')
          ).to eq('a=100000&b=bucket&k=secret_id&e=0&t=0&r=8888&f=/file/id')

          expect do
              s.string_to_sign(:aaa, 'bucket')
          end.to raise_error(Exception)
        end
      end
    end

    # 测试单次签名是否正确
    it 'should get correct once signature' do

      value = 'uHttFnTdOl0Gav10HilAyd48y0JhPTEwMDAwMCZiPWJ1Y2tldF9uYW1lJms9c2VjcmV0X2lkJmU9MCZ0PTAmcj05OTk5JmY9LzEwMDAwMC9idWNrZXRfbmFtZS9wYXRoL2ZpbGUx'

      Time.stub :now, Time.at(0) do
        s = Signature.new(@config)

        s.stub(:rand, 9999) do
          expect(
            s.once('bucket_name', '/path/file1')
          ).to eq(value)

          expect(
              s.once('bucket_name', 'path/file1')
          ).to eq(value)
        end
      end

    end

    # 测试多次签名是否正确
    it 'should get correct multiple signature' do

      value = '5Z8lOVnqnB+edqjced24dmJu2gZhPTEwMDAwMCZiPWJ1Y2tldF9uYW1lJms9c2VjcmV0X2lkJmU9NjAwJnQ9MCZyPTk5OTkmZj0='

      Time.stub :now, Time.at(0) do
        s = Signature.new(@config)

        s.stub(:rand, 9999) do
          expect(
              s.multiple('bucket_name', 600)
          ).to eq(value)

          expect do
            s.multiple('bucket_name', 0)
          end.to raise_error(AttrError)
        end
      end

    end

  end

end