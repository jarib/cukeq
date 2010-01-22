module CukeQ
  class Runner

    DEFAULT_TRIGGER_URI = URI.parse("http://localhost:9292/")

    def self.execute(args)
      opts = parse(args)
      uri = opts[:uri]

      EM.run {
        http = EM::P::HttpClient.request(
          :host    => uri.host,
          :port    => uri.port,
          :verb    => "POST",
          :request => uri.path.empty? ? "/" : uri.path,
          :content => options[:features].to_json
        )

        http.callback do |response|
          log :success, message,
          EM.stop
        end

        http.errback do |error|
          log :error, error[:status], uri.to_s

          EM.stop
        end

      }
    end

    private

    def self.parse(argv)
      options = {:uri => DEFAULT_TRIGGER_URI}

      argv.extend OptionParser::Arguable
      argv.options do |opts|
        opts.on("-u", "--uri URI (default: #{DEFAULT_TRIGGER_URI})") do |str|
          options[:uri] = URI.parse(str)
        end
      end.parse!

      if argv.empty?
        raise "must provide list of features"
      end

      options[:features] = argv

      options
    end

  end # Runner
end # CukeQ