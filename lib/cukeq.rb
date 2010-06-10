require "amqp"
require "mq"
require "rack/handler/thin"
require "json"

require "uri"
require "etc"
require "pp"
require "optparse"
require "socket"

require "cukeq/broker"
require "cukeq/webapp"
require "cukeq/scm"
require "cukeq/scm/git_bridge"

# begin
#   require "cukeq/scm/svn_bridge"
# rescue LoadError
#   require "cukeq/scm/simple_svn_bridge"
# end

require "cukeq/reporter"
require "cukeq/scenario_exploder"
require "cukeq/scenario_runner"

require "cukeq/master"
require "cukeq/slave"
require "cukeq/job_clearer"
require "cukeq/runner"

module CukeQ
  def self.identifier
    @identifier ||= "#{Socket.gethostname}-#{Etc.getlogin}"
  end
end

def log(*args)
  args.unshift Time.now
  str = args.map { |e| e.inspect }.join "  |  "

  $stdout.puts str
  $stdout.flush
end
