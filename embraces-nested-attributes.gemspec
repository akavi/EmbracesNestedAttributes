# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active-record-ex/version'

Gem::Specification.new do |spec|
  spec.name          = 'embraces-nested-attributes'
  spec.version       = ActiveRecordEx::VERSION
  spec.authors       = ['Arjun Kavi', 'PagerDuty']
  spec.email         = ['arjun.kavi@gmail.com', 'developers@pagerduty.com']
  spec.license       = 'MIT'
  spec.summary       = 'Optional extensions to ActiveRecord::Base.accepts_nested_attributes'
  spec.description   = 'A bunch of little things to make accepts_nested_attributes even more awesome.'
  spec.homepage      = 'https://github.com/akavi/EmbracesNestedAttributes'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'test-unit'
  spec.add_development_dependency 'shoulda'
  spec.add_development_dependency 'mocha'

  spec.add_runtime_dependency 'activesupport', '~> 3.2'
  spec.add_runtime_dependency 'activerecord', '~> 3.2'
end
