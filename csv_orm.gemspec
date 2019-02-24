# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'csv_orm/version'

Gem::Specification.new do |spec|
  spec.name          = "csv_orm"
  spec.version       = CsvOrm::VERSION
  spec.authors       = ["Mike Lerner"]
  spec.email         = ["cheeseandpepper@gmail.com"]

  spec.summary       = %q{A quick and dirty activerecord like orm for csv files.}
  spec.description   = %q{Because I hate excel, I'd rather query my csv files like I would query a db}
  spec.homepage      = "http://www.google.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'csv'
  spec.add_development_dependency 'ostruct'
  spec.add_development_dependency 'pry'
end
