module CukeQ
  class App

    def initialize(master)
      @master = master
    end

    def call(env)
      if env['REQUEST_METHOD'] != 'POST'
        return [405, {'Allow' => 'POST'}, '']
      end

      begin
        data = JSON.parse(env['rack.input'].read)
        @master.process(data)
      rescue JSON::ParserError
        return [406, {'Content-Type' => 'application/json'}, '']
      end

      [202, {}, 'ok']
    end

  end # App
end # CukeQ