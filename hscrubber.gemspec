# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "hscrubber/version"

Gem::Specification.new do |s|
  s.name        = "hscrubber"
  s.version     = HScrubber::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors      = [ 'Малъ Скрылёвъ (Malo Skrylevo)' ]
  s.email        = [ '3aHyga@gmail.com' ]
  s.homepage     = 'https://github.com/3aHyga/hscrubber'
  s.summary      = 'hscrubber is HTML scrubber'
  s.description  = 'hscrubber is HTML scrubber based on a HTML reha filter'

  s.executables  = [ 'hscrub' ]
  s.rubyforge_project = "hscrubber"

  s.required_rubygems_version = '>= 1.6.0'

  s.add_dependency 'hpricot', ">= 0.8.4"

  s.add_development_dependency("bundler", ">= 1.0.0")
  s.add_development_dependency("rspec", "~> 2.0.1")

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
