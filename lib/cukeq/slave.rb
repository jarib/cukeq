module CukeQ
  class Slave

    def self.execute(argv)
      opts = parse(argv)
      new(
        opts[:host] || 'localhost',
        opts[:port] || 5672,
        opts[:user] || 'cukeq-slave',
        opts[:pass] || 'cukeq123'
      ).run
    end

    def self.parse(argv)
      options = {}

      argv.extend(OptionParser::Arguable)
      argv.options do |opts|
        opts.on("-b", "--broker HOST:PORT") do |b|
          host, port = b.split(":", 2)
          options[:host] = host || 'localhost'
          options[:port] = port || 5672
        end

        opts.on("-u", "--user USER") { |u| options[:user] = u }
        opts.on("-p", "--password PASS") { |p| options[:pass] = p }
      end.parse!

      options
    end

    def initialize(host, port, user, pass)
      @host = host
      @port = Integer(port)
      @user = user
      @pass = pass
    end

    def job(message)
      p :new_job => message
      # process job here, then:
      @result_queue.publish("I received #{message.inspect}")
    end

    def run
      p :started => amqp_options
      AMQP.start(amqp_options) do
        @result_queue = MQ.new.queue("cukeq.results")
        @job_queue    = MQ.new.queue("cukeq.jobs")

        @job_queue.subscribe &method(:job)
      end
    end

    def amqp_options
      {
        :host    => @host,
        :port    => @port,
        :user    => @user,
        :pass    => @pass,
        :vhost   => '/cukeq',
        :timeout => 20
      }
    end
  end # Slave
end # CukeQ