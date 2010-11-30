require "net/http"

module CukeQHelper

  MASTER_ARGS = %w[--scm git://github.com/jarib/cukeq.git --report-to http://localhost:1212]

  def cleanup
    pids.each { |pid| Process.kill(:KILL, pid) }
    Process.wait
  end

  def start_master
    pids << fork { CukeQ::Master.execute(MASTER_ARGS) }
    ensure_running
    ensure_listening(master_url)
  end

  def start_slave
    pids << fork { CukeQ::Slave.execute }
    ensure_running
  end

  def start_report_app
    app = report_app()

    pids << fork { app.start }

    ensure_running
    ensure_listening(app.url)
  end

  def post(url, data)
    uri = URI.parse(url)
    req = Net::HTTP::Post.new(uri.path)
    req.body = data

    execute_request uri, req
  end

  def get(url)
    uri = URI.parse(url)
    execute_request uri, Net::HTTP::Get.new(uri.path)
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

  def ensure_listening(url)
    max_time = Time.now + 10
    until listening?(url)
      if Time.now > max_time
        raise "timed out waiting for #{url} to respond"
      end
      sleep 0.1
    end
  end

  def report_app
    @report_app ||= ReportApp.new
  end

  def pids
    @pids ||= []
  end

  def execute_request(url, req)
    res = Net::HTTP.new(url.host, url.port).start { |http| http.request(req) }

    case res
    when Net::HTTPSuccess
      res.body
    else
      res.error!
    end
  end

  def listening?(url)
    uri = URI.parse(url)
    TCPSocket.new(uri.host, uri.port).close
    true
  rescue
    false
  end

end
