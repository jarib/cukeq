# encoding: utf-8

require "tmpdir"
require "fileutils"

module CukeQ
  class ScenarioRunner

    attr_reader :repos

    def initialize(repo_directory = nil)
      @repos = repo_directory || CukeQ.root
    end

    def run(job, &callback)
      scm = scm_for job

      Dir.chdir scm.working_copy
      run_job(scm.working_copy, job, callback)
    rescue => ex
      yield :success   => false,
            :error     => ex.message,
            :backtrace => ex.backtrace,
            :run       => job['run']
    end

    def scm_for(job)
      url = job['scm']['url']
      rev = job['scm']['revision']

      scm = Scm.new(@repos, url)
      unless scm.current_revision.to_s == rev.to_s
        # TODO(jari): this doesn't ensure that current_revision == rev - it
        # would also make sense to move the logic to Scm
        scm.update {} # hmm.
      end

      scm
    end

    def run_job(working_copy, job, callback)
      AsyncJob.new(working_copy, job, callback).run
    end

  end # ScenarioRunner
end # CukeQ

