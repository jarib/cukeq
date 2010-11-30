class TestEnvironment
  def self.launch
    env = new
    env.start
    at_exit { env.stop }
  end

  def initialize
    @rabbit = RabbitControl.new
  end

  def start
    @rabbit.start
  end

  def stop
    @rabbit.stop
  end
end
