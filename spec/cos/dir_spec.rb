# coding: utf-8

require 'spec_helper'

module COS

  describe COSDir do

    before :all do
      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/?op=stat").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {authority:'eWRPrivate'}}.to_json)

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/test/?op=stat").
          to_return(:status => 200, :body => {data:{name: 'test', ctime: @time, mtime: @time, biz_attr: ''}}.to_json)

      @config = {
          app_id: '100000',
          secret_id: 'secret_id',
          secret_key: 'secret_key',
          protocol: 'http',
          default_bucket: 'bucket_name'
      }
      @bucket = Client.new(@config).bucket('bucket_name')
      @dir = @bucket.stat('test/')
    end

    it 'test upload all files to dir' do
      @time = Time.now.to_i.to_s

      local_path = "/tmp/cos_test/#{Time.now.to_i}"
      FileUtils::mkdir_p(local_path)

      File.open("#{local_path}/test.txt", 'w') do |f|
        (1..10).each do |i|
          f.puts i.to_s.rjust(10, '0')
        end
      end

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/test/?op=stat").
          to_return(:status => 200, :body => {data:{name: 'd1', ctime: @time, mtime: @time, biz_attr: ''}}.to_json)

      stub_request(:post, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/test/test.txt")
          .to_return(:status => 200, :body => {
              code: 0, message: 'ok', data: {session: 'session', slice_size: 10000, offset: 0, access_url: 'access_url'}
          }.to_json)

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/test/test.txt?op=stat").
          to_return(:status => 200, :body => {data:{name: 'test.txt', ctime: @time, mtime: @time, biz_attr: '', filesize: 100, filelen: 100, access_url: 'url'}}.to_json)

      uploads = @dir.upload_all(local_path, skip_error: true)

      expect(uploads[0].path).to eq('/test/test.txt')
    end

    it 'test download all files to local path' do
      @time = Time.now.to_i.to_s

      local_path = "/tmp/cos_test/d_#{Time.now.to_i}"
      FileUtils::mkdir_p(local_path)

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/test/?context=&num=20&op=list&order=0&pattern=eListFileOnly").
          to_return(:status => 200, :body => {
              code: 0,
              message: 'ok',
              data: {
                  has_more: false,
                  dircount: 1,
                  filecount: 1,
                  context: '',
                  infos: [
                                {name: 'file1.txt', ctime: @time, mtime: @time, sha: '1111', biz_attr: '', filesize: 100, filelen:100, access_url: 'url'},
                            ]
              }
          }.to_json, :headers => {})

      stub_request(:get, %r{^(http?:\/\/)url\/\?sign=[^\s]+}).to_return(:status => 200, :body => "11111111111", :headers => {})

      d = @dir.download_all(local_path)
      expect(d).to eq(["#{local_path}/file1.txt"])
    end

    it 'test get dir hash tree' do

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/test/?context=&num=1&op=list&order=0&pattern=eListBoth").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {
              has_more: false,
              context: '',
              dircount: 2,
              filecount: 0,
              infos: [
                            {name: 'path1-1', ctime: Time.now.to_i.to_s, mtime: Time.now.to_i.to_s, biz_attr: ''},
                            {name: 'path1-2', ctime: Time.now.to_i.to_s, mtime: Time.now.to_i.to_s, biz_attr: ''},
                        ]
          }}.to_json)

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/test/?context=&num=20&op=list&order=0&pattern=eListDirOnly").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {
              has_more: false,
              context: '',
              dircount: 2,
              filecount: 1,
              infos: [
                            {name: 'path1-1', ctime: Time.now.to_i.to_s, mtime: Time.now.to_i.to_s, biz_attr: ''},
                            {name: 'path1-2', ctime: Time.now.to_i.to_s, mtime: Time.now.to_i.to_s, biz_attr: ''},
                        ]
          }}.to_json)

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/test/path1-1/?context=&num=1&op=list&order=0&pattern=eListDirOnly").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {
              has_more: false,
              context: '',
              dircount: 0,
              filecount: 0,
              infos: []
          }}.to_json)

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/test/path1-1/?context=&num=20&op=list&order=0&pattern=eListDirOnly").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {
              has_more: false,
              context: '',
              dircount: 0,
              filecount: 0,
              infos: []
          }}.to_json)

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/test/path1-2/?context=&num=20&op=list&order=0&pattern=eListDirOnly").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {
              has_more: false,
              dircount: 0,
              filecount: 0,
              context: '',
              infos: [
                            {name: 'path1-2-1', ctime: Time.now.to_i.to_s, mtime: Time.now.to_i.to_s, biz_attr: ''},
                            {name: 'path1-2-2', ctime: Time.now.to_i.to_s, mtime: Time.now.to_i.to_s, biz_attr: ''},
                            {name: 'f1', ctime: @time, mtime: @time, biz_attr: '', filesize: 100, filelen:100, access_url: 'url'},
                        ]
          }}.to_json)

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/test/path1-2/?context=&num=1&op=list&order=0&pattern=eListDirOnly").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {
              has_more: false,
              context: '',
              dircount: 2,
              filecount: 1,
              infos: [
                            {name: 'path1-2-1', ctime: Time.now.to_i.to_s, mtime: Time.now.to_i.to_s, biz_attr: ''},
                            {name: 'path1-2-2', ctime: Time.now.to_i.to_s, mtime: Time.now.to_i.to_s, biz_attr: ''},
                            {name: 'f1', ctime: @time, mtime: @time, biz_attr: '', filesize: 100, filelen:100, access_url: 'url'},
                        ]
          }}.to_json)

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/test/path1-2/path1-2-1/?context=&num=1&op=list&order=0&pattern=eListDirOnly").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {
              has_more: false,
              context: '',
              dircount: 0,
              filecount: 0,
              infos: []
          }}.to_json)

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/test/path1-2/path1-2-1/?context=&num=20&op=list&order=0&pattern=eListDirOnly").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {
              has_more: false,
              context: '',
              dircount: 0,
              filecount: 0,
              infos: [
                            {name: 'f1', ctime: @time, mtime: @time, biz_attr: '', filesize: 100, filelen:100, access_url: 'url'},
                        ]
          }}.to_json)

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/test/path1-2/path1-2-2/?context=&num=1&op=list&order=0&pattern=eListDirOnly").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {
              has_more: false,
              dircount: 0,
              filecount: 0,
              context: '',
              infos: []
          }}.to_json)

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/test/path1-2/path1-2-2/?context=&num=20&op=list&order=0&pattern=eListDirOnly").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {
              has_more: false,
              dircount: 0,
              filecount: 0,
              context: '',
              infos: []
          }}.to_json)

      expect(@dir.hash_tree[:resource][:name]).to eq('test')
    end

  end

end