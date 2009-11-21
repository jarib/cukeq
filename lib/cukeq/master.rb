module CukeQ
  class Master

    class << self
      def execute(argv)
        opts = parse(argv)

        new(
          opts[:broker]    || "localhost:5672",
          opts[:trigger]   || "localhost:9292",
          opts[:scm]       || raise(ArgumentError, "must provide --scm"),
          opts[:report_to] || raise(ArgumentError, "must provide --report-to"),
          opts[:user]      || 'cukeq-master',
          opts[:pass]      || 'cukeq123'
        ).run
      end

      private

      def parse(argv)
        options = {}

        argv.extend OptionParser::Arguable
        argv.options do |opts|
          opts.on("-b", "--broker HOST:PORT") do |str|
            opts[:broker] = str
          end

          opts.on("-t", "--trigger HOST:PORT") do |str|
            opts[:trigger] = str
          end

          opts.on("-s", "--scm SCM-URL") do |url|
            options[:scm] = Scm.new(url)
          end

          opts.on("-r", "--report-to REPORTER-URL") do |url|
            options[:report_to] = Reporter.new(url)
          end

          opts.on("-u", "--username USER") { |u| options[:user] = u}
          opts.on("-p", "--password PASS") { |p| options[:pass] = p}
        end.parse!

        options
      end
    end

    def initialize(broker, trigger, scm, reporter, user, pass)
      broker_host, broker_port   = broker.split(":", 2)
      @broker_host = broker_host
      @broker_port = Integer(broker_port)

      trigger_host, trigger_port = trigger.split(":", 2)
      @trigger_host = trigger_host
      @trigger_port = Integer(trigger_port)

      @scm      = scm
      @reporter = reporter
      @user     = user
      @pass     = pass
    end

    def run
      p :starting => amqp_options
      AMQP.start(amqp_options) do

        @result_queue = MQ.new.queue("cukeq.results")
        @job_queue    = MQ.new.queue("cukeq.jobs")

        @result_queue.subscribe &method(:result)

        @trigger = Rack::Handler::Thin.run(App.new(self), :Host => @trigger_host, :Port => @trigger_port)
      end
    end

    def process(data)
      # TODO: fetch latest from @scm, call cucumber to get exploded scenarios
      publish data
    end

    private

    def result(message)
      p :result => message
      @reporter.report(message)
    end

    def publish(message)
      p :publish => message
      @job_queue.publish(message)
    end

    def amqp_options
      {
        :host    => @broker_host,
        :port    => @broker_port,
        :user    => @user,
        :pass    => @pass,
        :vhost   => '/cukeq',
        :timeout => 20
      }
    end

  end # Master
end # CukeQ