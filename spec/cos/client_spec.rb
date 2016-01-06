require 'spec_helper'

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
      expect(
          Client.new(@config).bucket('bucket_name').bucket_name
      ).to eq('bucket_name')
    end

  end

end