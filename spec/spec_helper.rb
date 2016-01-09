# coding: utf-8

require 'simplecov'
SimpleCov.start

# require 'coveralls'
# Coveralls.wear!
require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'webmock/rspec'
require 'cos'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

end

COS::Logging::set_logger(nil, Logger::DEBUG)
