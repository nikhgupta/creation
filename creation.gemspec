# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'creation/version'

Gem::Specification.new do |spec|
  spec.name          = "creation"
  spec.version       = Creation::VERSION
  spec.authors       = ["Nikhil Gupta"]
  spec.email         = ["me@nikhgupta.com"]

  spec.summary       = %q{Generates Rails applications in a highly opinionated way.}
  spec.description   = %q{Generates Rails applications in a highly opinionated way.}
  spec.homepage      = "http://github.com/nikhgupta/creation"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  # spec.add_development_dependency "aruba"
  # spec.add_development_dependency "cucumber"
  spec.add_development_dependency "pry"

  spec.add_dependency "rails", "~> #{Creation::RAILS_VERSION}"
  # spec.add_dependency "activeadmin", "~> #{Creation::ACTIVE_ADMIN_VERSION}"
end
