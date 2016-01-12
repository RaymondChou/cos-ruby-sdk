# coding: utf-8

require 'spec_helper'

module COS

  describe Download do

    before :all do
      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/?op=stat").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {}}.to_json)

      @config = {
          app_id: '100000',
          secret_id: 'secret_id',
          secret_key: 'secret_key',
          protocol: 'http',
          default_bucket: 'bucket_name'
      }
      COS.client(@config).bucket
    end

    it 'should download entire file' do
      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/d_path/file1?op=stat").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {name: 'f1', ctime: @time, mtime: @time, biz_attr: '', filesize: 100, filelen:100, access_url: 'url', sha: '123'}}.to_json)

      stub_request(:get, %r{^(http?:\/\/)url\/\?sign=[^\s]+}).to_return(:status => 200, :body => "11111111111", :headers => {})

      file = COS.client.bucket.stat('/d_path/file1')
      local = file.download('/tmp/file11')

      expect(File.read(local)).to eq('11111111111')
    end

    it 'should download entire file exist' do
      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/d_path/file1?op=stat").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {name: 'f1', ctime: @time, mtime: @time, biz_attr: '', filesize: 100, filelen:100, access_url: 'url', sha: '7D4EEBAB7CE33F2C5D6D8C6240CC8FE65EA14CD7'}}.to_json)

      File.open('/tmp/file11', 'wb') do |f|
        f.write('11111111111')
      end
      file = COS.client.bucket.stat('/d_path/file1')
      local = file.download('/tmp/file11')

      expect(File.read(local)).to eq('11111111111')
    end

    it 'should download slice file raise error' do
      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/d_path/file2?op=stat").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {name: 'f1', ctime: @time, mtime: @time, biz_attr: '', filesize: 100, filelen:100, access_url: 'url1', sha: '123'}}.to_json)

      stub_request(:get, %r{^(http?:\/\/)url1\/\?sign=[^\s]+}).to_return(:status => 200, :body => "1", :headers => {})

      file = COS.client.bucket.stat('/d_path/file2')

      expect do
        file.download('/tmp/file2', min_slice_size: 10)
      end.to raise_error(DownloadError)

    end

    it 'should download slice file' do
      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/d_path/file3?op=stat").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {name: 'f1', ctime: @time, mtime: @time, biz_attr: '', filesize: 100, filelen:100, access_url: 'url3', sha: '356a192b7913b04c54574d18c28d46e6395428ab'}}.to_json)

      stub_request(:get, %r{^(http?:\/\/)url3\/\?sign=[^\s]+}).to_return(:status => 200, :body => "1", :headers => {})

      file = COS.client.bucket.stat('/d_path/file3')

      prog = []
      local = file.download('/tmp/file33', {min_slice_size: 10}) do |pr|
        prog << pr
      end

      expect(File.read(local)).to eq('1')

      expect(prog.size).to eq(4)

      File.delete(local) if File.exist?(local)
    end

    it 'should download slice file and checkpoint file exist' do
      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/d_path/file3?op=stat").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {name: 'f1', ctime: @time, mtime: @time, biz_attr: '', filesize: 100, filelen:100, access_url: 'url3', sha: '356a192b7913b04c54574d18c28d46e6395428ab'}}.to_json)

      stub_request(:get, %r{^(http?:\/\/)url3\/\?sign=[^\s]+}).to_return(:status => 200, :body => "1", :headers => {})

      file = COS.client.bucket.stat('/d_path/file3')

      # 创建cpt
      cpt_file = '/tmp/file44.cpt'
      File.open(cpt_file, 'w') do |f|
        f << '{"session": "session", "sha1":"f1a4cca1a5b3e43a35fbad14a93bbfeec584f5de", "file_meta":{"sha1":"356a192b7913b04c54574d18c28d46e6395428ab"}, "parts":[{"number":1,"done":false,"range":[0,100]}], "slice_size":10000, "file_size":100, "offset":0}'
      end

      prog = []
      local = file.download('/tmp/file44', {min_slice_size: 10}) do |pr|
        prog << pr
      end

      expect(File.read(local)).to eq('1')

      File.delete(local) if File.exist?(local)
    end

  end

end