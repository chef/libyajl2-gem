# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'libyajl2/version'

Gem::Specification.new do |spec|
  spec.name          = "libyajl2"
  spec.version       = Libyajl2::VERSION
  spec.authors       = ["lamont-granquist"]
  spec.email         = ["lamont@scriptkiddie.org"]
  spec.summary       = %q{Installs a vendored copy of libyajl2 for distributions which lack it}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/lamont-granquist/libyajl2-gem"
  spec.licenses       = ["Apache 2.0"]

  spec.files         = `git ls-files -z`.split("\x0") +
                       `cd ext/libyajl2/vendor/yajl && git ls-files -z`.split("\x0").map { |p| p.sub!(/^/, 'ext/libyajl2/vendor/yajl/') }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ["lib"]

  spec.extensions = Dir["ext/**/extconf.rb"]

  # required for 'rake spec'
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rake-compiler"
  spec.add_development_dependency "rspec", "~> 2.14"
  spec.add_development_dependency "ffi", "~> 1.9"
end
