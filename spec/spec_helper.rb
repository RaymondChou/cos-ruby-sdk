# coding: utf-8

require 'simplecov'
require "codeclimate-test-reporter"

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    CodeClimate::TestReporter::Formatter
]

SimpleCov.start

require 'webmock/rspec'
require 'cos'

WebMock.disable_net_connect!(allow: %w{codeclimate.com})

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

end

COS::Logging::set_logger(STDOUT, Logger::DEBUG)
