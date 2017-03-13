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

  spec.required_ruby_version = '>= 2.2'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rr"
  spec.add_development_dependency "test-unit"
  spec.add_development_dependency "test-unit-rr"
  spec.add_development_dependency "yard"

  spec.add_dependency "nokogiri"
  spec.add_dependency "oauth"
end
