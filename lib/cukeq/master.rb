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
      @scm      = scm
      @reporter = reporter
      @exploder = exploder
      @webapp   = webapp

      @run_id   = 0
    end

    def start
      @scm.update

      @broker.start do
        subscribe
        start_webapp
      end
    end

    #
    # This is triggered by POSTs to the webapp
    #

    def run(data)
      scm = {:revision => @scm.current_revision, :url => @scm.url }

      units = Dir.chdir(@scm.working_copy) do
        @exploder.explode(data)
      end

      run_id = next_run_id()

      units.each do |unit|
        @broker.publish(
          :jobs, {
            :run_id          => run_id,
            :scm             => scm,
            :unit            => unit,
            # :pre_run_command => "gem bundle; echo 'webdriver.enabled = true' > config/user.prop" # HACK!
          }.to_json
        )

        log self.class, :publisehd, unit
      end
    end

    #
    # Called whenever a result is received on the results queue
    #

    def result(message)
      log self.class, :result, message

      @reporter.report(message)
    end

    def subscribe
      @broker.subscribe :results do |message|
        next unless message
        result(JSON.parse(message))
      end
    end

    def start_webapp
      @webapp.run method(:run)
    end

    def next_run_id
      @run_id += 1
    end

  end # Master
end # CukeQ