module CukeQ
  class Scm
    class SvnBridge

      def initialize(url, working_copy)
        @url          = url
        @working_copy = working_copy
      end

      def update
        raise NotImplementedError
      end

      def current_revision
        raise NotImplementedError
      end

    end # SvnBridge
  end # Scm
end # CukeQ