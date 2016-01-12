# coding: utf-8

require 'spec_helper'

module COS

  describe Tree do

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

    it 'should create tree object' do
      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/path1/?op=stat").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {name: 'path1', ctime: Time.now.to_i.to_s, mtime: Time.now.to_i.to_s, biz_attr: ''}}.to_json)

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/path1/?context=&num=20&op=list&order=0&pattern=eListDirOnly").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {
              has_more: false,
              context: '',
              infos: [
                            {name: 'path1-1', ctime: Time.now.to_i.to_s, mtime: Time.now.to_i.to_s, biz_attr: ''},
                            {name: 'path1-2', ctime: Time.now.to_i.to_s, mtime: Time.now.to_i.to_s, biz_attr: ''}
                        ]
          }}.to_json)

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/path1/path1-1/?context=&num=20&op=list&order=0&pattern=eListDirOnly").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {
              has_more: false,
              context: '',
              infos: []
          }}.to_json)

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/path1/path1-2/?context=&num=20&op=list&order=0&pattern=eListDirOnly").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {
              has_more: false,
              context: '',
              infos: []
          }}.to_json)

      tree = COS.client.bucket.tree('path1')

      expect(tree[:children][1][:resource].name).to eq('path1-2')
    end

    it 'should create tree hash' do
      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/path1/?op=stat").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {name: 'path1', ctime: Time.now.to_i.to_s, mtime: Time.now.to_i.to_s, biz_attr: ''}}.to_json)

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/path1/?context=&num=20&op=list&order=0&pattern=eListDirOnly").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {
              has_more: false,
              context: '',
              infos: [
                            {name: 'path1-1', ctime: Time.now.to_i.to_s, mtime: Time.now.to_i.to_s, biz_attr: ''},
                            {name: 'path1-2', ctime: Time.now.to_i.to_s, mtime: Time.now.to_i.to_s, biz_attr: ''}
                        ]
          }}.to_json)

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/path1/path1-1/?context=&num=20&op=list&order=0&pattern=eListDirOnly").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {
              has_more: false,
              context: '',
              infos: []
          }}.to_json)

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/path1/path1-2/?context=&num=20&op=list&order=0&pattern=eListDirOnly").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {
              has_more: false,
              context: '',
              infos: []
          }}.to_json)

      tree = COS.client.bucket.hash_tree('path1')

      expect(tree[:children][1][:resource][:name]).to eq('path1-2')
    end

    it 'should print tree in command line' do
      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/?op=stat").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {name: '', ctime: Time.now.to_i.to_s, mtime: Time.now.to_i.to_s, biz_attr: ''}}.to_json)

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/?context=&num=1&op=list&order=0&pattern=eListBoth").
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

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/?context=&num=20&op=list&order=0&pattern=eListBoth").
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

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/path1-1/?context=&num=1&op=list&order=0&pattern=eListBoth").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {
              has_more: false,
              context: '',
              dircount: 0,
              filecount: 0,
              infos: []
          }}.to_json)

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/path1-1/?context=&num=20&op=list&order=0&pattern=eListBoth").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {
              has_more: false,
              context: '',
              dircount: 0,
              filecount: 0,
              infos: []
          }}.to_json)

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/path1-2/?context=&num=20&op=list&order=0&pattern=eListBoth").
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

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/path1-2/?context=&num=1&op=list&order=0&pattern=eListBoth").
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

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/path1-2/path1-2-1/?context=&num=1&op=list&order=0&pattern=eListBoth").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {
              has_more: false,
              context: '',
              dircount: 0,
              filecount: 0,
              infos: []
          }}.to_json)

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/path1-2/path1-2-1/?context=&num=20&op=list&order=0&pattern=eListBoth").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {
              has_more: false,
              context: '',
              dircount: 0,
              filecount: 0,
              infos: [
                         {name: 'f1', ctime: @time, mtime: @time, biz_attr: '', filesize: 100, filelen:100, access_url: 'url'},
                     ]
          }}.to_json)

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/path1-2/path1-2-2/?context=&num=1&op=list&order=0&pattern=eListBoth").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {
              has_more: false,
              dircount: 0,
              filecount: 0,
              context: '',
              infos: []
          }}.to_json)

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/path1-2/path1-2-2/?context=&num=20&op=list&order=0&pattern=eListBoth").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {
              has_more: false,
              dircount: 0,
              filecount: 0,
              context: '',
              infos: []
          }}.to_json)

      path_obj = COS.client.bucket.stat
      COS::Tree.new({path: path_obj, files: true, files_count: true}).print_tree
    end

    it 'should get tree in COSFile' do
      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/?op=stat").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {name: '', ctime: Time.now.to_i.to_s, mtime: Time.now.to_i.to_s, biz_attr: ''}}.to_json)

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/?context=&num=1&op=list&order=0&pattern=eListBoth").
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

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/?context=&num=20&op=list&order=0&pattern=eListBoth").
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

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/path1-1/?context=&num=1&op=list&order=0&pattern=eListBoth").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {
              has_more: false,
              context: '',
              dircount: 0,
              filecount: 0,
              infos: []
          }}.to_json)

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/path1-1/?context=&num=20&op=list&order=0&pattern=eListBoth").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {
              has_more: false,
              context: '',
              dircount: 0,
              filecount: 0,
              infos: []
          }}.to_json)

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/path1-2/?context=&num=20&op=list&order=0&pattern=eListBoth").
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

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/path1-2/?context=&num=1&op=list&order=0&pattern=eListBoth").
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

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/path1-2/path1-2-1/?context=&num=1&op=list&order=0&pattern=eListBoth").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {
              has_more: false,
              context: '',
              dircount: 0,
              filecount: 0,
              infos: []
          }}.to_json)

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/path1-2/path1-2-1/?context=&num=20&op=list&order=0&pattern=eListBoth").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {
              has_more: false,
              context: '',
              dircount: 0,
              filecount: 0,
              infos: [
                            {name: 'f1', ctime: @time, mtime: @time, biz_attr: '', filesize: 100, filelen:100, access_url: 'url'},
                        ]
          }}.to_json)

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/path1-2/path1-2-2/?context=&num=1&op=list&order=0&pattern=eListBoth").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {
              has_more: false,
              dircount: 0,
              filecount: 0,
              context: '',
              infos: []
          }}.to_json)

      stub_request(:get, "http://web.file.myqcloud.com/files/v1/100000/bucket_name/path1-2/path1-2-2/?context=&num=20&op=list&order=0&pattern=eListBoth").
          to_return(:status => 200, :body => { code: 0, message: 'ok', data: {
              has_more: false,
              dircount: 0,
              filecount: 0,
              context: '',
              infos: []
          }}.to_json)

      path_obj = COS.client.bucket.stat
      tree = path_obj.tree(files: true, files_count: true)

      # bucket root
      expect(tree[:resource].name).to eq('')
    end

  end

end
