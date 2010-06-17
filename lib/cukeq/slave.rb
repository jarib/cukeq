# encoding: utf-8

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
      @broker.start {
        ping_pong
        poll
      }
    end

    #
    # Publish a message on the results queue
    #

    def publish(message)
      log log_name, :publish, message[:run]
      @broker.publish :results, message.to_json
    end

    #
    # Run a job
    #

    def job(message)
      log log_name, :job, message

      @scenario_runner.run(message) { |result|
        publish(result)
        EM.next_tick { poll } # job done, start polling again
      }
    end

    POLL_INTERVAL = 0.25

    #
    # Poll for new jobs
    #

    def poll
      @broker.queue_for(:jobs).pop { |input|
        if input
          job JSON.parse(input)
        else
          EM.add_timer(POLL_INTERVAL) { poll }
        end
      }
    end

    #
    # Subscribe to :ping, respond to :pong
    #

    def ping_pong
      @broker.subscribe(:ping) { |message|
        log log_name, :ping
        @broker.publish :pong, {:id => CukeQ.identifier, :class => self.class.name}.to_json
      }
    end

    def log_name
      @log_name ||= [self.class, Process.pid]
    end

  end # Slave
end # CukeQ