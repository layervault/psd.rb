# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'psd/version'

Gem::Specification.new do |gem|
  gem.name          = "psd"
  gem.version       = PSD::VERSION
  gem.authors       = ["Ryan LeFevre"]
  gem.email         = ["ryan@layervault.com"]
  gem.description   = %q{Parse Photoshop save files with ease}
  gem.summary       = %q{General purpose library for parsing Photoshop save files}
  gem.homepage      = "http://github.com/layervault/psd.rb"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "bindata"
  gem.add_dependency "chunky_png"
  gem.add_dependency 'psd-enginedata'

  gem.test_files = Dir.glob("spec/**/*")
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'guard'
  gem.add_development_dependency 'guard-rspec'
  gem.add_development_dependency 'rb-fsevent', '~> 0.9'
end
