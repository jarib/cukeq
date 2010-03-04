require "git"

module CukeQ
  class Scm
    class GitBridge

      def initialize(url, working_copy)
        @url          = url
        @working_copy = working_copy
      end

      def update
        repo.reset_hard
        repo.pull
      end

      def current_revision
        repo.revparse("HEAD")
      end

      def repo
        @repo ||= (
          unless File.directory? @working_copy
            Git.clone(@url, @working_copy)
          end

          Git.open(@working_copy)
        )
      end

    end # GitBridge
  end # Scm
end # CukeQ
