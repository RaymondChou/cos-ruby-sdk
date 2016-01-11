# coding: utf-8

require 'spec_helper'
require 'fileutils'
require 'yaml'

module COS

  describe Client do

    before :all do
      @config = {
          app_id: '100000',
          secret_id: 'secret_id',
          secret_key: 'secret_key',
          protocol: 'http',
          default_bucket: 'bucket_name'
      }
    end

    it 'get the signature access' do
      expect(
          Client.new(@config).signature.class
      ).to be Signature
    end

    it 'get the bucket access' do
      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/?op=stat").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {}}.to_json)

      expect(
          Client.new(@config).bucket('bucket_name').bucket_name
      ).to eq('bucket_name')
    end

    it 'bucket name must be set' do
      expect do
        client = Client.new({
                       app_id: '100000',
                       secret_id: 'secret_id',
                       secret_key: 'secret_key'
                   })
        client.bucket
      end.to raise_error(ClientError)
    end

    it 'Rails init client' do
      Object.const_set('Rails', Class.new do
        def self.root
          ['/tmp/', '']
        end
      end)

      FileUtils::mkdir_p('/tmp/log')
      FileUtils::mkdir_p('/tmp/config')

      yml = {
          'app_id'         => '100000',
          'secret_id'      => 'secret_id',
          'secret_key'     => 'secret_key',
          'default_bucket' => 'bucket_name'
      }

      File.open('/tmp/config/cos.yml', 'w') do |f|
        f.write(yml.to_yaml)
      end

      client = COS.client

      expect(client.config.app_id).to eq('100000')

      Object.const_set('Rails', nil)
    end

  end

end