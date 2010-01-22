module CukeQ
  class Runner

    def self.execute(args)
      # TODO: parse args (uri)
      uri = URI.parse "http://localhost:9292/"

      Dir.chdir(args.first) do |dir|
        message = Dir[File.join(dir, "features/**/*.feature")].map do |f|
          f.gsub(%r[#{dir}/?], '')
        end
        EM.run {
          EM::P::HttpClient.request(
            :host    => uri.host,
            :port    => uri.port,
            :verb    => "POST",
            :request => uri.path.empty? ? "/" : uri.path,
            :content => message.to_json
          )


        }

        log :posted, message
      end
    end

  end # Runner
end # CukeQ