module CukeQ
  class WebApp
    attr_reader :uri

    def initialize(uri)
      @uri = uri
    end

    def run(callback)
      @callback = callback
      Rack::Handler::Thin.run(self, :Host => @uri.host, :Port => @uri.port)
    end

    def call(env)
      log self.class, :called

      request = Rack::Request.new(env)

      unless request.post?
        return [405, {'Allow' => 'POST'}, []]
      end

      begin
        data = JSON.parse(request.body.read)
        @callback.call(data) if @callback
      rescue JSON::ParserError
        return [406, {'Content-Type' => 'application/json'}, []]
      end

      [202, {}, %w[ok]]
    end

  end # App
end # CukeQ