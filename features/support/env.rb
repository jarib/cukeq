$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')

require 'rubygems'
require 'cukeq'
require 'rspec/expectations'
require File.expand_path("../report_app", __FILE__)
require File.expand_path("../cukeq_helper", __FILE__)
require File.expand_path("../test_environment", __FILE__)
require File.expand_path("../rabbit_control", __FILE__)

World(CukeQHelper)

TestEnvironment.launch

After do
  cleanup
end