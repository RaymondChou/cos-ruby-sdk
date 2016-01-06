require 'spec_helper'

module COS

  describe Bucket do

    before :all do
      @config = {
          app_id: '100000',
          secret_id: 'secret_id',
          secret_key: 'secret_key',
          protocol: 'http',
          default_bucket: 'bucket_name'
      }
      @bucket = Client.new(@config).bucket('bucket_name')
    end

    it 'should list folder' do
      stub_request(:get, 'http://web.file.myqcloud.com/files/v1/100000/bucket_name/path/?context=&num=20&op=list&order=0&pattern=eListBoth').
          to_return(:status => 200, :body => {
              code: 0,
              message: 'ok',
              data: {
                  has_more: false,
                  context: '',
                  infos: [
                      {name: 'f1', ctime: Time.now.to_i.to_s, mtime: Time.now.to_i.to_s, biz_attr: ''},
                      {name: 'f2', ctime: Time.now.to_i.to_s, mtime: Time.now.to_i.to_s, biz_attr: ''}
                         ]
              }
          }.to_json, :headers => {})

      size = 0
      @bucket.list('/path/', {}).each do |f|
        size += 1
      end

      expect(WebMock).to have_requested(:get, 'http://web.file.myqcloud.com/files/v1/100000/bucket_name/path/?context=&num=20&op=list&order=0&pattern=eListBoth')

      expect(size).to eq(2)
    end

    it 'should list folder and create folder' do

      stub_request(:get, 'http://web.file.myqcloud.com/files/v1/100000/bucket_name/path/?context=&num=20&op=list&order=0&pattern=eListBoth').
          to_return(:status => 200, :body => {
              code: 0,
              message: 'ok',
              data: {
                  has_more: false,
                  context: '',
                  infos: [
                                {name: 'd1', ctime: Time.now.to_i.to_s, mtime: Time.now.to_i.to_s, biz_attr: ''},
                                {name: 'd2', ctime: Time.now.to_i.to_s, mtime: Time.now.to_i.to_s, biz_attr: ''},
                                {name: 'f1', ctime: Time.now.to_i.to_s, mtime: Time.now.to_i.to_s, biz_attr: '', filesize: 100},
                            ]
              }
          }.to_json, :headers => {})

      stub_request(:post, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/path/d1/").to_return(:status => 200, :body => { code: 0, message: 'ok', data: {ctime: Time.now.to_i.to_s, mtime: Time.now.to_i.to_s}}.to_json)

      stub_request(:post, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/path/d1/path2/").to_return(:status => 200, :body => { code: 0, message: 'ok', data: {ctime: Time.now.to_i.to_s, mtime: Time.now.to_i.to_s}}.to_json)

      stub_request(:post, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/path/d2/").to_return(:status => 200, :body => { code: 0, message: 'ok', data: {ctime: Time.now.to_i.to_s, mtime: Time.now.to_i.to_s}}.to_json)

      stub_request(:post, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/path/d2/path2/").to_return(:status => 200, :body => { code: 0, message: 'ok', data: {ctime: Time.now.to_i.to_s, mtime: Time.now.to_i.to_s}}.to_json)

      stub_request(:post, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/path/f1").to_return(:status => 200, :body => { code: 0, message: 'ok', data: {ctime: Time.now.to_i.to_s, mtime: Time.now.to_i.to_s}}.to_json)

      @bucket.list('/path/', {}).each do |f|
        if f.is_a?(COS::COSDir) and f.type == 'dir'

          f.update('biz_attr')

          f.create_folder('path2')

        elsif f.is_a?(COS::COSFile) and f.type == 'file'

          f.delete
        else
          nil
        end
      end

      expect(WebMock).to have_requested(:get, 'http://web.file.myqcloud.com/files/v1/100000/bucket_name/path/?context=&num=20&op=list&order=0&pattern=eListBoth')

      expect(WebMock).to have_requested(:post, 'http://web.file.myqcloud.com/files/v1/100000/bucket_name/path/f1')
      expect(WebMock).to have_requested(:post, 'http://web.file.myqcloud.com/files/v1/100000/bucket_name/path/d1/')
      expect(WebMock).to have_requested(:post, 'http://web.file.myqcloud.com/files/v1/100000/bucket_name/path/d2/')

    end

  end

end