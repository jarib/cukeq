module CukeQ
  class Broker
    attr_reader :user, :pass, :host, :port, :vhost

    def initialize(uri, opts = {})
      @user    = uri.user     || raise(ArgumentError, "no user given")
      @pass    = uri.password || 'cukeq123'
      @host    = uri.host     || 'localhost'
      @port    = uri.port     || 5672
      @vhost   = uri.path     || '/cukeq'

      @timeout = Integer(opts[:timeout] || 20)
      @queues  = {}
    end

    def start
      log self.class, :start, "#{@host}:#{@port}#{@vhost}"

      AMQP.start(amqp_options) do
        create_queues
        yield if block_given?
      end
    end

    def publish(queue_name, json)
      queue_for(queue_name).publish(json)
    end

    def subscribe(queue_name, &blk)
      q = queue_for(queue_name).pop(&blk)
      EM.add_periodic_timer(0.25) { q.pop }
    end

    # def unsubscribe(queue_name, &blk)
    #   queue_for(queue_name).unsubscribe(&blk)
    # end

    def queue_for(name)
      @queues[name] || raise("unknown queue: #{name.inspect}")
    end

    private

    def create_queues
      @queues[:results] = MQ.new.queue("cukeq.results")
      @queues[:jobs]    = MQ.new.queue("cukeq.jobs")
    end

    def amqp_options
      {
        :host    => @host,
        :port    => @port,
        :user    => @user,
        :pass    => @pass,
        :vhost   => @vhost,
        :timeout => 20
      }
    end

  end # QueueHandler
end # CukeQ