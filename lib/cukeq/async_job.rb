module CukeQ
  class AsyncJob

    def initialize(working_copy, job, callback)
      @job          = job
      @callback     = callback
      @result       = {:success => true, :slave => CukeQ.identifier}
      @invoked      = false
      @working_copy = working_copy
    end

    def run
      parse_job

      EventMachine.system3 command, &method(:child_finished)
    rescue => ex
      handle_exception(ex)
    end

    private

    def handle_exception(ex)
      @result.merge!(:success => false, :error => ex.message, :backtrace => ex.backtrace, :cwd => Dir.pwd)
      cleanup
      invoke_callback
    end

    def invoke_callback
      if @invoked
        $stderr.puts "#{self} tried to invoke callback twice"
        return
      end

      @invoked = true
      @callback.call @result
    end

    def cleanup
      FileUtils.rm_rf(output_file) if File.exist?(output_file)
    end

    def command
      "bundle install && bundle exec cucumber -rfeatures --format Cucumber::Formatter::Json --out #{output_file} #{@feature_file}"
    end

    def child_finished(stdout, stderr, status)
      output = <<-OUT
  stdout:
  #{stdout}

  stderr:
  #{stderr}
      OUT

      @result.merge!(
        :output   => output,
        :stderr   => stderr,
        :stdout   => stdout,
        :success  => status.success?,
        :exitcode => status.exitstatus,
        :results  => fetch_results,
        :cwd      => Dir.pwd
      )
      cleanup
      invoke_callback
    rescue => ex
      handle_exception ex
    end

    def fetch_results
      return unless File.exist?(output_file)

      content = File.read(output_file)
      begin
        JSON.parse(content)
      rescue JSON::ParserError => ex
        raise JSON::ParserError, "#{ex.message} (#{content.inspect})"
      end
    end

    def parse_job
      @feature_file = @job['unit']['file']
      @run          = @job['run']
      @scm          = @job['scm']

      @result.merge!(:feature_file => @feature_file, :run => @run, :scm => @scm)
    end

    def output_file
      @output_file ||= "#{CukeQ.identifier}-#{@run['id']}.json"
    end

  end
end