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

    g.add_dependency "amqp"
    g.add_dependency "thin"
    g.add_dependency "json"
    g.add_dependency "git"

    g.add_development_dependency "rspec", ">= 1.2.9"
    g.add_development_dependency "yard", ">= 0"
    g.add_development_dependency "cucumber", ">= 0"
    g.add_development_dependency "rack-test", ">= 0"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'

task :default => ["spec:coverage", "spec:coverage:verify"]

Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ["--color", "--format", "progress"]
  t.spec_files = Dir['spec/**/*_spec.rb'].sort
  t.libs = ['lib']
  t.rcov = false
end

namespace :spec do
  Spec::Rake::SpecTask.new(:coverage) do |t|
    t.spec_opts = ["--color", "--format", "progress"]
    t.spec_files = Dir['spec/**/*_spec.rb'].sort
    t.libs = ['lib']
    t.rcov = true
    t.rcov_opts = ['--exclude-only', '".*"', '--include-file', '^lib']
  end

  namespace :coverage do
    RCov::VerifyTask.new(:verify) do |t|
      t.threshold = 100
      t.index_html = "coverage/index.html"
    end
  end
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

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
