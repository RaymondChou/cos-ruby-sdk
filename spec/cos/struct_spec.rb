# coding: utf-8

require 'spec_helper'

module COS

  describe Struct do

    it 'should raise AttrError when miss required atrrs' do
      expect do
        Config.new({
                       app_id: '100000',
                       secret_id: 'secret_id',
                   })
      end.to raise_error(AttrError)
    end

    it 'should raise AttrError when give extra attrs' do
      expect do
        Config.new({
                       aaaa: 11111,
                       app_id: '100000',
                       secret_id: 'secret_id',
                       secret_key: 'secret_key',
                       protocol: 'http',
                       default_bucket: 'bucket_name'
                   })
      end.to raise_error(AttrError)
    end

    it 'should use default logger' do
      Logging.instance_variable_set(:@logger, nil)
      expect(Logging.logger.level).to eq(Logger::INFO)
    end

  end

end