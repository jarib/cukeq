require "amqp"
require "mq"
require "rack/handler/thin"
require "json"

require "uri"
require "pp"
require "optparse"

require "cukeq/broker"
require "cukeq/webapp"
require "cukeq/scm"
require "cukeq/scm/git_bridge"
require "cukeq/scm/svn_bridge"
require "cukeq/reporter"
require "cukeq/scenario_exploder"
require "cukeq/scenario_runner"

require "cukeq/master"
require "cukeq/slave"
require "cukeq/runner"

module CukeQ
end

def log(*args)
  p [Time.now, *args]
end
