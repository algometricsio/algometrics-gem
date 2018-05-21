# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'algometrics/version'

Gem::Specification.new do |spec|
  spec.name          = "algometrics"
  spec.version       = Algometrics::VERSION
  spec.authors       = ["Alex Kurkin"]
  spec.email         = ["alex@algometrics.io"]

  spec.summary       = "Algometrics API client for sending events to algometrics.io"
  spec.description   = "Send events to algometrics.io and monitor your workflows in real-time."
  spec.homepage      = "https://github.com/algometricsio/algometrics-gem"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'faraday', '~> 0.12.2'

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
