# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'environmentor/version'

Gem::Specification.new do |spec|
  spec.name          = "environmentor"
  spec.version       = Environmentor::VERSION
  spec.authors       = ["Dan Brown"]
  spec.email         = ["dan@madebymany.co.uk"]
  spec.summary       = %q{TODO: Write a short summary. Required.}
  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.7"
  spec.add_development_dependency "minitest-reporters", "~> 1.0"
  spec.add_development_dependency "wrong"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "simplecov", ">= 0.9"
end
