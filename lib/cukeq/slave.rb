module CukeQ
  class Slave
    DEFAULT_BROKER_URI = URI.parse("amqp://cukeq-slave:cukeq123@localhost:5672/cukeq")

    class << self
      def execute(argv = [])
        configured_instance(argv).start
      end

      def configured_instance(argv = [])
        opts = parse(argv)

        if b = opts[:broker]
          b.user     ||= DEFAULT_BROKER_URI.user
          b.password ||= DEFAULT_BROKER_URI.password
          b.host     ||= DEFAULT_BROKER_URI.host
          b.port     ||= DEFAULT_BROKER_URI.port
          b.path     = b.path.empty? ? DEFAULT_BROKER_URI.path : b.path
        else
          opts[:broker] = DEFAULT_BROKER_URI
        end

        new(
          Broker.new(opts[:broker]),
          ScenarioRunner.new
        )
      end

      def parse(argv)
        options = {}

        argv.extend(OptionParser::Arguable)
        argv.options do |opts|
          opts.on("-b", "--broker URI (default: #{DEFAULT_BROKER_URI})") do |b|
            options[:broker] = URI.parse(b)
          end

        end.parse!

        options
      end
    end # class << self

    attr_reader :broker, :scenario_runner

    def initialize(broker, scenario_runner)
      @broker          = broker
      @scenario_runner = scenario_runner
    end

    def start
      @broker.start { subscribe }
    end

    def job(message)
      log log_name, :job, message
      @scenario_runner.run(message) { |result| publish(result) }
    end

    #
    # Publish a message on the results queue
    #

    def publish(message)
      log log_name, :publish, message
      @broker.publish :results, message.to_json
    end

    def subscribe
      @broker.subscribe :jobs do |message|
        next unless message
        job JSON.parse(message)
      end
    end

    def log_name
      [self.class, Process.pid]
    end

  end # Slave
end # CukeQ