require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |g|
    g.name        = "cukeq"
    g.summary     = %Q{Distributed cucumbers}
    g.description = %Q{Cucumber features distributed using AMQP.}
    g.email       = "jari.bakken@gmail.com"
    g.homepage    = "http://github.com/jarib/cukeq"
    g.authors     = ["Jari Bakken"]
    g.bindir      = 'bin'
    g.executables = Dir['bin/*'].map { |f| File.basename(f) }

    g.add_dependency "amqp"
    g.add_dependency "thin"
    g.add_dependency "json"

    g.add_development_dependency "rspec", ">= 1.2.9"
    g.add_development_dependency "yard", ">= 0"
    g.add_development_dependency "cucumber", ">= 0"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
  spec.rcov_opts = %w[--exclude spec,ruby-debug,/Library/Ruby,.gem --include lib/cukeq]
end

task :spec => :check_dependencies

begin
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:features)

  task :features => :check_dependencies
rescue LoadError
  task :features do
    abort "Cucumber is not available. In order to run features, you must: sudo gem install cucumber"
  end
end

task :default => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
