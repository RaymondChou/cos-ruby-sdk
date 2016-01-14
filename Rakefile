#!/usr/bin/env rake

require 'bundler'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

# Rspec 单元测试
RSpec::Core::RakeTask.new(:spec) do
  Bundler.setup(:default, :test)
end

# 运行示例
task :example do
  FileList['example/**/*.rb'].each do |f|
    puts "==== Run example: #{f} ===="
    ruby f
  end
end

require 'rake/testtask'

# 集成测试
Rake::TestTask.new do |t|
  t.pattern = 'test/**/*_test.rb'
end

task :default => :spec
