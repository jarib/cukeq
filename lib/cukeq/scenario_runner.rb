module CukeQ
  class ScenarioRunner

    def run(job, &callback)
      raise NotImplementedError

      # Run the exploded scenario job using cucumber's wire protocol,
      # and report each step result using callback.call()
    end

  end # ScenarioRunner
end # CukeQ