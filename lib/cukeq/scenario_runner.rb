module CukeQ
  class ScenarioRunner

    def run(job, &callback)
      new_scm job.fetch(:scm)

      if job_revision != @scm.current_revision
        update_and_restart
        @last_revision = job_revision
      end

      # TODO: run cucumber
      #
      # Run the exploded scenario job and report each step result using callback.call()

      # for now, just yield the job arg
      yield job
    rescue => e
      # errors here should be reported as a result
    end

    def update_and_restart
      @scm.update
      # TODO: restart cucumber
    end

    def new_scm(info)
      @scm              = Scm.new info[:url]
      @current_revision = info.fetch(:revision)
    end

  end # ScenarioRunner
end # CukeQ