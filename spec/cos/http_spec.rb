# coding: utf-8

require 'spec_helper'

module COS

  describe HTTP do

    before :all do
      @config = {
          app_id: '100000',
          secret_id: 'secret_id',
          secret_key: 'secret_key',
          protocol: 'http',
          default_bucket: 'bucket_name'
      }
    end

    # 发送正确的http请求并包含鉴权header
    it 'should set http Authorization with right url' do

      @http = COS::HTTP.new(Config.new(@config))

      stub_request(:get, 'http://web.file.myqcloud.com/files/v1/bucket_name/path/').
          to_return(:status => 200, :body => {code: 0, message: 'ok'}.to_json, :headers => {})

      @http.get('/bucket_name/path/', {}, 'sign')

      expect(WebMock)
          .to have_requested(:get, 'http://web.file.myqcloud.com/files/v1/bucket_name/path/')
                  .with{ |req| req.headers.has_key?('Authorization') }
    end

    # 正确抛出服务器错误返回
    it 'should raise server exception when 400' do

      @http = COS::HTTP.new(Config.new(@config))

      stub_request(:get, 'http://web.file.myqcloud.com/files/v1/bucket_name/path/').
          to_return(:status => 400, :body => {code: -19, message: 'some errors'}.to_json, :headers => {})

      # ServerError
      expect do
        @http.get('/bucket_name/path/', {}, 'sign')
      end.to raise_error(ServerError, 'some errors')

      expect(WebMock)
          .to have_requested(:get, 'http://web.file.myqcloud.com/files/v1/bucket_name/path/')
    end

    # 发送正确的post并解析data
    it 'should send post and parse data' do

      @http = COS::HTTP.new(Config.new(@config))

      stub_request(:post, 'http://web.file.myqcloud.com/files/v1/bucket_name/path/file').
          to_return(:status => 200, :body => {code: 0, message: 'ok', data: {count:10}}.to_json, :headers => {})

      expect(
          @http.post('/bucket_name/path/file', {}, 'sign', {biz_attr: 'test'})
      ).to eq({count: 10})

      expect(WebMock)
          .to have_requested(:post, 'http://web.file.myqcloud.com/files/v1/bucket_name/path/file')

    end

  end

end