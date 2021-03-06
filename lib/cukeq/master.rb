module CukeQ
  class Master
    DEFAULT_BROKER_URI = URI.parse("amqp://cukeq-master:cukeq123@localhost:5672/cukeq")
    DEFAULT_WEBAPP_URI = URI.parse("http://0.0.0.0:9292")

    class << self
      def execute(argv)
        configured_instance(argv).start
      end

      def configured_instance(argv)
        opts = parse(argv)

        raise ArgumentError, "must provide --scm" unless opts[:scm]
        raise ArgumentError, "must provide --report_to" unless opts[:report_to]

        if b = opts[:broker]
          b.user     ||= DEFAULT_BROKER_URI.user
          b.password ||= DEFAULT_BROKER_URI.password
          b.host     ||= DEFAULT_BROKER_URI.host
          b.port     ||= DEFAULT_BROKER_URI.port
          b.path     = b.path.empty? ? DEFAULT_BROKER_URI.path : b.path
        else
          opts[:broker] = DEFAULT_BROKER_URI
        end

        if w = opts[:webapp]
          w.host ||= DEFAULT_WEBAPP_URI.host
          w.port ||= DEFAULT_WEBAPP_URI.port
        else
          opts[:webapp] = DEFAULT_WEBAPP_URI
        end

        new(
          Broker.new(opts[:broker]),
          WebApp.new(opts[:webapp]),
          Scm.new(opts[:scm]),
          Reporter.new(opts[:report_to]),
          ScenarioExploder.new
        )
      end

      def parse(argv)
        options = {}

        argv.extend OptionParser::Arguable
        argv.options do |opts|
          opts.on("-b", "--broker URI (default: #{DEFAULT_BROKER_URI})") do |str|
            options[:broker] = URI.parse(str)
          end

          opts.on("-w", "--webapp URI (default: http://localhost:9292)") do |str|
            options[:webapp] = URI.parse(str)
          end

          opts.on("-s", "--scm SCM-URL") do |url|
            options[:scm] = URI.parse(url)
          end

          opts.on("-r", "--report-to REPORTER-URL") do |url|
            options[:report_to] = URI.parse(url)
          end
        end.parse!

        options
      end
    end # class << self

    attr_reader :broker, :webapp, :scm, :reporter, :exploder

    def initialize(broker, webapp, scm, reporter, exploder)
      @broker   = broker
      @webapp   = webapp
      @scm      = scm
      @reporter = reporter
      @exploder = exploder
    end

    def start
      @scm.update {
        @broker.start {
          subscribe
          start_webapp
        }
      }
    end

    def ping(&blk)
      log self.class, :ping
      @broker.subscribe :pong, &blk
      @broker.publish   :ping, '{}'
    end

    #
    # This is triggered by POSTs to the webapp
    #
    # data:
    #
    # { 'features' => (sent to exploder), 'run_id' => ID }
    #

    def run(data)
      Dir.chdir(@scm.working_copy) do
        @exploder.explode(data['features']) { |units| publish_units(data, units) }
      end
    end

    def publish_units(data, units)
      scm = { :revision => @scm.current_revision, :url => @scm.url }
      run = { :id => data['run_id'], :no_of_units => units.size}

      units.each do |unit|
        @broker.publish(
          :jobs, {
            :run         => run,
            :scm         => scm,
            :unit        => unit,
          }.to_json
        )

        log self.class, :published, unit
      end
    end

    #
    # Called whenever a result is received on the results queue
    #

    def result(message)
      log self.class, :result, message['run']
      @reporter.report message
    end

    def subscribe
      @broker.subscribe :results do |message|
        next unless message
        result(JSON.parse(message))
      end
    end

    def start_webapp
      log self.class, :start_webapp
      @webapp.run method(:run)
    end

  end # Master
end # CukeQ
