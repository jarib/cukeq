module CukeQ
  class ScenarioRunner

    def run(job, &callback)
      # Run the exploded scenario job using cucumber's wire protocol,
      # and report each step result using callback.call()

      # for now, just yield the job arg
      yield job
    end

  end # ScenarioRunner
end # CukeQ