# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'SCMAdapter/version'

Gem::Specification.new do |spec|
  spec.name          = "SCMAdapter"
  spec.version       = SCMAdapter::VERSION
  spec.authors       = ["nmeylan"]
  spec.email         = ["nmeylan@gmail.com"]
  spec.summary       = %q{This is a SCM adapter}
  spec.description   = %q{SCM adapter  is a simple Ruby library for interacting with common SCMs, such as Git, Mercurial (Hg) and SubVersion (SVN). }
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(spec|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rspec'
end
