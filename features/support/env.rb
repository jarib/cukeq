$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')

require 'rubygems'
require 'cukeq'
require 'spec/expectations'
require File.dirname(__FILE__) + "/report_app"
require File.dirname(__FILE__) + "/cukeq_helper"

World(CukeQHelper)

After do
  cleanup
end