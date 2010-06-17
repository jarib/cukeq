# encoding: utf-8

require "tmpdir"
require "fileutils"

module CukeQ
  class ScenarioRunner

    def run(job, &callback)
      scm = scm_for job
      run_job(scm.working_copy, job, callback)
    rescue => ex
      yield :success => false, :error => ex.message, :backtrace => ex.backtrace
    end

    def scm_for(job)
      url = job['scm']['url']
      rev = job['scm']['revision']

      scm = Scm.new(url)
      unless scm.current_revision.to_s == rev.to_s
        # TODO(jari): this doesn't ensure that current_revision == rev - it
        # would also make sense to move the logic to Scm
        scm.update
      end

      scm
    end

    def run_job(job, callback)
      AsyncJob.new(job, callback).run
    end

  end # ScenarioRunner
end # CukeQ

class AsyncJob

  def initialize(working_copy, job, callback)
    @job          = job
    @callback     = callback
    @result       = {:success => true, :slave => CukeQ.identifier}
    @working_copy = working_copy
    @invoked      = false
  end

  def run
    parse_job

    Dir.chdir(working_copy) {
      EventMachine.system3 command, &method(:child_finished)
    }
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
    "cucumber -rfeatures --format Cucumber::Formatter::Json --out #{output_file} #{@feature_file}"
  end

  def child_finished(stdout, stderr, status)
    output = <<-OUT
stdout:
#{stdout}

stderr:
#{stderr}
    OUT

    @result.merge!(:output => output, :success => status.success?, :results => fetch_results, :cwd => Dir.pwd)
  rescue => ex
    handle_exception ex
  ensure
    cleanup
    invoke_callback
  end

  def fetch_results
    return unless File.exist?(output_file)
    content = File.read(output_file)
    begin
      JSON.parse(output_file)
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
