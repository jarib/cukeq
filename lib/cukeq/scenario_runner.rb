require "tmpdir"
require "fileutils"

module CukeQ
  class ScenarioRunner

    def run(job, &callback)
      scm = scm_for job

      Dir.chdir(scm.working_copy) do
        yield result_for(job)
      end

    rescue => e
      yield(:success => false, :error => e.message, :backtrace => e.backtrace)
    end

    def scm_for(job)
      url = job['scm']['url']
      rev = job['scm']['revision']

      scm = Scm.new(url)
      unless scm.current_revision == rev
        # TODO(jari): this doesn't ensure that current_revision == rev - it
        # would also make sense to move the logic to Scm
        scm.update
      end

      scm
    end

    def result_for(job)
      returned = {:success => true, :slave => CukeQ.identifier}

      begin
        run_pre_run_if_necessary(job)

        feature_file = job['unit']['file']
        run          = job['run']
        scm          = job['scm']

        returned.merge!(:feature_file => feature_file, :run => run, :scm => scm)

        tmp_file = "#{CukeQ.identifier}-#{run['id']}.json"

        output  = %x[cucumber -rfeatures --format Cucumber::Formatter::Json --out #{tmp_file} #{feature_file} 2>&1]
        success = $?.success?
        results = read_json(tmp_file) if File.exist?(tmp_file)

        returned.merge(:output => output, :success => success, :results => results, :cwd => Dir.pwd)
      rescue => e
        returned.merge!(:success => false, :error => e.message, :backtrace => e.backtrace, :cwd => Dir.pwd)
        output ? returned.merge(:output => output) : returned
      ensure
        FileUtils.rm(tmp_file) if tmp_file && File.exist?(tmp_file)
      end
    end

    def run_pre_run_if_necessary(job)
      cmd = job['pre_run_command']

      return if cmd.nil?
      # TODO: only run if revision has changed since last run

      output = %x[#{cmd} 2>&1]

      unless $?.success?
        raise "pre-run command failed with status #{$?.exitstatus}\n#{output}"
      end
    end

    def read_json(file)
      content = File.read(file)
      begin
        JSON.parse content
      rescue JSON::ParserError => e
        raise JSON::ParserError, "#{e.message}: #{content.inspect}"
      end
    end

  end # ScenarioRunner
end # CukeQ
