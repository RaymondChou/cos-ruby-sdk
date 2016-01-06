require 'spec_helper'

module COS

  describe Slice do

    before :all do
      config = {
          app_id: '100000',
          secret_id: 'secret_id',
          secret_key: 'secret_key',
          protocol: 'http',
          default_bucket: 'bucket_name'
      }
      @client = Client.new(config)
      @config = @client.config

      @file = './file_to_upload.log'
      @file_path = '/path/path2/'
      @file_name = 'test_file'

      File.open(@file, 'w') do |f|
        (1..100).each do |i|
          f.puts i.to_s.rjust(100, '0')
        end
      end
    end

    before :each do
      File.delete("#{@file}.cpt") if File.exist?("#{@file}.cpt")
    end

    after :each do
      File.delete("#{@file}.cpt") if File.exist?("#{@file}.cpt")
    end

    it 'should upload file' do

      stub_request(:post, 'http://web.file.myqcloud.com/files/v1/100000/bucket_name/path/path2/test_file')
          .to_return(:status => 200, :body => {
              code: 0, message: 'ok', data: {session: 'session', slice_size: 100, offset: 0}
          }.to_json).then
          .to_return(:status => 200, :body => {
              code: 0, message: 'ok', data: {session: 'session', access_url: 'access_url'}
          }.to_json)

      prg = []

      progress = proc do |p|
        prg << p
      end

      @slice = Slice.new(
          config:    @config,
          http:      @client.api.http,
          path:      @file_path,
          file_name: @file_name,
          file_src:  @file,
          options:   {},
          progress:  progress
      ).upload


      expect(File.exist?("#{@file}.cpt")).to be false

      expect(prg.size).to eq(104)
    end

    it 'should upload file raise error' do

      File.delete("#{@file}.cpt") if File.exist?("#{@file}.cpt")

      stub_request(:post, 'http://web.file.myqcloud.com/files/v1/100000/bucket_name/path/path2/test_file')
          .to_return(:status => 200, :body => {
              code: 0, message: 'ok', data: {session: 'session', slice_size: 100, offset: 0}
          }.to_json).then
          .to_return(:status => 400, :body => {
              code: -111, message: 'error', data: {session: 'session', slice_size: 100, offset: 0}
          }.to_json)

      prg = []

      progress = proc do |p|
        prg << p
      end

      expect do
        @slice = Slice.new(
            config:    @config,
            http:      @client.api.http,
            path:      @file_path,
            file_name: @file_name,
            file_src:  @file,
            options:   {disable_cpt: true},
            progress:  progress
        ).upload
      end.to raise_error(ServerError)
    end

    it 'should upload file return in first thread' do

      File.delete("#{@file}.cpt") if File.exist?("#{@file}.cpt")

      stub_request(:post, 'http://web.file.myqcloud.com/files/v1/100000/bucket_name/path/path2/test_file').
          to_return(:status => 200, :body => {
              code: 0, message: 'ok', data: {access_url: 'access_url'}
          }.to_json)

      prg = []

      progress = proc {}

      @slice2 = Slice.new(
          config:    @config,
          http:      @client.api.http,
          path:      @file_path,
          file_name: @file_name,
          file_src:  @file,
          options: {disable_cpt: true},
          progress:  progress
      ).upload

      expect(@slice2[:access_url]).to eq('access_url')
    end

    it 'should upload file return in first thread' do

      stub_request(:post, 'http://web.file.myqcloud.com/files/v1/100000/bucket_name/path/path2/test_file').
          to_return(:status => 200, :body => {
              code: 0, message: 'ok', data: {access_url: 'access_url'}
          }.to_json)

      prg = []

      progress = proc {}

      @slice2 = Slice.new(
          config:    @config,
          http:      @client.api.http,
          path:      @file_path,
          file_name: @file_name,
          file_src:  @file,
          options: {},
          progress:  progress
      ).upload

      # expect(WebMock).to have_requested(
      #                        :post, 'http://web.file.myqcloud.com/files/v1/100000/bucket_name/path/path2/test_file').times(1)

      # expect(File.exist?("#{@file}.cpt")).to be false

      expect(prg.size).to eq(0)

      expect(@slice2[:access_url]).to eq('access_url')
    end

    it 'should raise error slice_size error' do
      expect do
        Slice.new(
            config:    @config,
            http:      @client.api.http,
            path:      @file_path,
            file_name: @file_name,
            file_src:  @file,
            options:   {slice_size: 0}
        ).upload
      end.to raise_error(ClientError, 'slice_size must > 0')
    end

    it 'should upload file load form cpt file with missing sha1' do

      # 创建cpt
      cpt_file = './test.cpt.log'
      File.open(cpt_file, 'w') do |f|
        f << '{"session": "session"}'
      end

      stub_request(:post, 'http://web.file.myqcloud.com/files/v1/100000/bucket_name/path/path2/test_file').
          to_return(:status => 200, :body => {
              code: 0, message: 'ok', data: {session: 'session', slice_size: 10000, offset: 0}
          }.to_json)

      prg = []

      progress = proc {}

      expect do
        @slice = Slice.new(
            config:    @config,
            http:      @client.api.http,
            path:      @file_path,
            file_name: @file_name,
            file_src:  @file,
            options:   {cpt_file: cpt_file},
            progress:  progress
        ).upload
      end.to raise_error(CheckpointBrokenError, 'Missing SHA1 in checkpoint.')

      File.delete(cpt_file) if File.exist?(cpt_file)
    end

    it 'should upload file load form cpt file with change' do

      # 创建cpt
      cpt_file = './test.cpt.log'
      File.open(cpt_file, 'w') do |f|
        f << '{"session": "session", "sha1":"1111", "file_meta":{"sha1":"1111"}}'
      end

      stub_request(:post, 'http://web.file.myqcloud.com/files/v1/100000/bucket_name/path/path2/test_file').
          to_return(:status => 200, :body => {
              code: 0, message: 'ok', data: {session: 'session', slice_size: 10000, offset: 0}
          }.to_json)

      prg = []

      progress = proc {}

      expect do
        @slice = Slice.new(
            config:    @config,
            http:      @client.api.http,
            path:      @file_path,
            file_name: @file_name,
            file_src:  @file,
            options:   {cpt_file: cpt_file},
            progress:  progress
        ).upload
      end.to raise_error(CheckpointBrokenError, 'Unmatched checkpoint SHA1')
      File.delete(cpt_file) if File.exist?(cpt_file)
    end

    it 'should upload file load form cpt file with wrong sha1' do

      # 创建cpt
      cpt_file = './test.cpt.log'
      File.open(cpt_file, 'w') do |f|
        f << '{"session": "session", "sha1":"a51796cf06a44d611992c6fc796c62b10da95ccf", "file_meta":{"sha1":"1111"}, "parts":[], "slice_size":10000, "file_size":'+File.size(@file).to_s+', "offset":0}'
      end

      stub_request(:post, 'http://web.file.myqcloud.com/files/v1/100000/bucket_name/path/path2/test_file').
          to_return(:status => 200, :body => {
              code: 0, message: 'ok', data: {session: 'session', slice_size: 10000, offset: 0}
          }.to_json)

      prg = []

      progress = proc {}

      expect do
        @slice = Slice.new(
            config:    @config,
            http:      @client.api.http,
            path:      @file_path,
            file_name: @file_name,
            file_src:  @file,
            options:   {cpt_file: cpt_file},
            progress:  progress
        ).upload
      end.to raise_error(FileInconsistentError, 'The file to upload is changed')
      File.delete(cpt_file) if File.exist?(cpt_file)
    end

    it 'should upload file finished' do

      # 创建cpt
      cpt_file = './test.cpt.log'
      File.open(cpt_file, 'w') do |f|
        f << '{"session": "session", "sha1":"ea32e288faa633f692cb2d7025a8ddaf54bf6516", "file_meta":{"sha1":"afbd38119325969a447bddee2dae8fd822de138f"}, "parts":[{"number":1,"done":true}], "slice_size":10000, "file_size":'+File.size(@file).to_s+', "offset":0}'
      end

      stub_request(:post, 'http://web.file.myqcloud.com/files/v1/100000/bucket_name/path/path2/test_file').
          to_return(:status => 400, :body => {
              code: -288, message: 'ok', data: {session: 'session', access_url: 'access_url'}
          }.to_json)

      prg = []

      progress = proc do |p|
        prg << p
      end

      expect(
          Slice.new(
              config:    @config,
              http:      @client.api.http,
              path:      @file_path,
              file_name: @file_name,
              file_src:  @file,
              options:   {cpt_file: cpt_file},
              progress:  progress
          ).upload
      ).to eq(nil)

      File.delete(cpt_file) if File.exist?(cpt_file)
    end

  end

end