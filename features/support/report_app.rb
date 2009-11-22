class ReportApp

  def url
    "http://localhost:#{port}"
  end
  
  def port
    1212
  end
  
  def start
    Rack::Handler::Thin.run(self, :Port => port)
  end
  
  def results
    @results ||= []
  end
  
  def call(env)
    r = Rack::Request.new(env)
    if r.post?
      results << JSON.parse(r.body.read)
    elsif r.get?
      case r.path
      when "/results"
        return [200, {}, results]
      when "/clear"
        results.clear
      else
        return [404, {}, []]
      end
    end
    
    [200, {}, []]
  end
end