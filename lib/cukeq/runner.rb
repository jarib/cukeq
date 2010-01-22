module CukeQ
  class Runner

    DEFAULT_TRIGGER_URI = URI.parse("http://localhost:9292/")

    def self.execute(args)
      opts = parse(args)
      uri = opts[:uri]

      Dir.chdir(opts[:dir]) do |dir|
        message = Dir[File.join(dir, "features/**/*.feature")].map do |f|
          f.gsub(%r[#{dir}/?], '')
        end
        EM.run {
          http = EM::P::HttpClient.request(
            :host    => uri.host,
            :port    => uri.port,
            :verb    => "POST",
            :request => uri.path.empty? ? "/" : uri.path,
            :content => message.to_json
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

      options[:dir] =  argv.shift || raise("must provide scm directory")

      options
    end

  end # Runner
end # CukeQ