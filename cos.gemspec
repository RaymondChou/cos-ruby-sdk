# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cos/version'

Gem::Specification.new do |spec|
  spec.name          = 'cos'
  spec.version       = COS::VERSION
  spec.authors       = ['RaymondChou']
  spec.email         = ['freezestart@gmail.com']

  spec.summary       = %q{Tencent COS Ruby SDK.}
  spec.description   = %q{Tencent Cloud Object Service Ruby SDK.}
  spec.homepage      = 'http://github.com/RaymondChou'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|example)/}) }
  spec.test_files    = Dir.glob('spec/**/*_spec.rb') + Dir.glob('test/**/*.rb')
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.license       = 'Apache 2.0'

  spec.add_dependency 'rest-client', '~> 1.8'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.4'
  spec.add_development_dependency 'rspec', '~> 3.3'
  spec.add_development_dependency 'webmock', '~> 1.22'
  spec.add_development_dependency 'simplecov', '~> 0.10'
  spec.add_development_dependency 'minitest', '~> 5.8'

  spec.required_ruby_version = '>= 1.9.3'
end
