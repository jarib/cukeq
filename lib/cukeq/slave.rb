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
      log self.class, :job, message
      @scenario_runner.run(message) { |result| publish(result.to_json) }
    end

    #
    # Publish a message on the results queue
    #

    def publish(message)
      log self.class, :publish, message
      # might need to process the message here?
      @broker.publish :results, message
    end

    def subscribe
      @broker.subscribe :jobs do |message|
        job JSON.parse(message)
      end
    end

  end # Slave
end # CukeQ