# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cukeq/version"

Gem::Specification.new do |s|
  s.name        = "cukeq"
  s.version     = CukeQ::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jari Bakken"]
  s.email       = ["jari.bakken@gmail.com"]
  s.homepage    = "http://github.com/jarib/cukeq"
  s.summary     = %Q{Distributed cucumbers}
  s.description = %Q{Cucumber features distributed using AMQP.}

  s.rubyforge_project = "cukeq"

  s.add_runtime_dependency "amqp",      ">= 0"
  s.add_runtime_dependency "thin",      ">= 0"
  s.add_runtime_dependency "json",      ">= 0"
  s.add_runtime_dependency "git",       ">= 0"
  s.add_runtime_dependency "nokogiri",  ">= 0"

  s.add_development_dependency "rspec",     ">= 2.0.0"
  s.add_development_dependency "yard",      ">= 0"
  s.add_development_dependency "cucumber",  ">= 0"
  s.add_development_dependency "rack-test", ">= 0"
  s.add_development_dependency "childprocess", ">= 0.1.4"
  s.add_development_dependency "ruby-debug19"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
