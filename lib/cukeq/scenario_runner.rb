require "tmpdir"
require "fileutils"

module CukeQ
  class ScenarioRunner

    def run(job, &callback)
      # return yield(job) # FIXME: `rake features` expects this
      scm = scm_for job

      Dir.chdir(scm.working_copy) do
        yield result_for(job)
      end
    end

    def scm_for(job)
      url = job['scm']['url']
      rev = job['scm']['revision']

      scm = Scm.new(url)
      unless scm.current_revision == rev
        scm.update
      end

      scm
    end

    def result_for(job)
      returned = {:success => true, :slave => CukeQ.identifier}

      begin
        feature_file = job['unit']['file']
        run_id       = job['run_id']

        run_pre_run_if_necessary(job)

        returned.merge!(:feature_file => feature_file, :run_id => run_id)

        tmp_dir      = Dir.mktmpdir("runid#{run_id}")

        output  = %x[cucumber -rfeatures --format junit --out #{tmp_dir} #{feature_file} 2>&1]
        success = $?.success?
        results = Dir[File.join(tmp_dir, '*.xml')].map { |file| File.read(file) }

        returned.merge(:output => output, :success => success, :results => results)
      rescue => e
        returned.merge(:success => false, :error => e.message, :backtrace => e.backtrace)
      ensure
        FileUtils.rm_rf(tmp_dir) if tmp_dir && File.exist?(tmp_dir)
      end
    end

    def run_pre_run_if_necessary(job)
      cmd = job['pre_run_command']
      return unless cmd

      output = %x[#{cmd} 2>&1]

      unless $?.success?
        raise "pre-run command failed with status #{$?.exitstatus}\n#{output}"
      end
    end

  end # ScenarioRunner
end # CukeQ