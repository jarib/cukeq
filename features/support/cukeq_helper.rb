require "restclient"

module CukeQHelper
  
  MASTER_ARGS = %w[--scm git://github.com/jarib/cukeq.git --report-to http://localhost:1212]
  
  def cleanup
    pids.each { |pid| Process.kill(:KILL, pid) }
    Process.wait
  end
  
  def start_master
    pids << fork { CukeQ::Master.execute(MASTER_ARGS) } 
    ensure_running
  end
  
  def start_slave
    pids << fork { CukeQ::Slave.execute }
    ensure_running
  end
  
  def start_report_app
    app = report_app()
    
    pids << fork { app.start }
    ensure_running
  end
  
  def post(url, data)
    uri = URI.parse(url)
    
    EM.run {
      EM::P::HttpClient.request(
        :host    => uri.host, 
        :port    => uri.port,
        :verb    => "POST",
        :request => uri.path,
        :content => data
      )
    }
  end
  
  def get(url)
    EM.run {
      EM::P::HttpClient.request(
        :host    => uri.host, 
        :port    => uri.port,
        :verb    => "GET",
        :request => uri.path
      )
    }
  end
  
  def master_url
    "http://localhost:9292/"
  end
  
  def ensure_running
    3.times do
      pid, status = Process.waitpid2(pids.last, Process::WNOHANG)
      raise "process died: #{status.inspect}" if pid
      sleep 0.5
    end
  end
  
  def report_app
    @report_app ||= ReportApp.new
  end
  
  def pids
    @pids ||= []
  end
  
end