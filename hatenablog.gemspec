# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hatenablog/version'

Gem::Specification.new do |spec|
  spec.name          = "hatenablog"
  spec.version       = Hatenablog::VERSION
  spec.authors       = ["Kohei Yamamoto"]
  spec.email         = ["kymmt90@gmail.com"]

  spec.summary       = %q{Hatenablog AtomPub API library}
  spec.description   = %q{Hatenablog AtomPub API library}
  spec.homepage      = "https://github.com/kymmt90/hatenablog"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.0'

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rr", "~> 1.1.2"
  spec.add_development_dependency "test-unit", "~> 3.1.4"
  spec.add_development_dependency "test-unit-rr", "~> 1.0.3"
  spec.add_development_dependency "yard", "~> 0.8.7"

  spec.add_dependency "nokogiri", "~> 1.6.6"
  spec.add_dependency "oauth", "~> 0.4.7"
end
