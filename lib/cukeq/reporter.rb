module CukeQ
  class Reporter
    attr_reader :uri

    def initialize(uri)
      @uri = uri
    end

    def report(message)
      EM::P::HttpClient.request(
        :host    => uri.host,
        :port    => uri.port,
        :verb    => "POST",
        :request => uri.path.empty? ? "/" : uri.path,
        :content => message.to_json
      )
    rescue => e # EM raises a RuntimeError..
      log self.class, "error for #{uri}: #{e.message}"
    end

  end # Reporter
end # CukeQ