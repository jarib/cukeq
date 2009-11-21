module CukeQ
  class Reporter
    attr_reader :url

    def initialize(url)
      @url = URI.parse(url)
    end

    def report(message)
      EM::P::HttpClient.request(
        :host    => @url.host,
        :port    => @url.port,
        :verb    => "POST",
        :request => @url.path.empty? ? "/" : @url.path,
        :content => message
      )
    rescue => e # EM raises a RuntimeError..
      $stderr.puts "error for #{@url}: #{e.message}"
    end

  end # Reporter
end # CukeQ