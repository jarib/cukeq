require "tempfile"
require "childprocess"

class RabbitControl

  TIMEOUT = 10

  def initialize
    @tmp     = Tempfile.new("rabbit-control")
    @process = ChildProcess.build("rabbitmq-server")

    @process.io.stdout = @tmp
    @process.io.stderr = @tmp
  end

  def start
    @process.start

    max_time = Time.now + TIMEOUT

    until running?
      if Time.now > max_time
        raise "timed out waiting for rabbitmq-server"
      end
      sleep 0.1
    end

    system "rabbitmqctl list_users 2>&1"
    raise "rabbit error: #{out}" unless $?.success?

    true
  end

  def stop
    @process.stop
    @tmp.close!
  end

  def running?
    @tmp.rewind
    output = @tmp.read
    puts output if $DEBUG
    output =~ /broker running/
  end

end

if __FILE__ == $0
  rabbitctl = RabbitControl.new
  trap("INT") { rabbitctl.stop }
  rabbitctl.start
  sleep
end