require "svn/client" # apt-get install libsvn-ruby

module CukeQ
  class Scm
    class SvnBridge

      def initialize(url, working_copy)
        @url          = url
        @working_copy = working_copy
      end

      def update
        client.update(@working_copy).to_s
      end

      def current_revision
        client.status(@working_copy).to_s
      end

      private

      def client
        @client ||= begin
          ctx = Svn::Client::Context.new


          unless File.directory? @working_copy
            log self.class, :checkout, @url.to_s => @working_copy
            ctx.checkout(@url.to_s, @working_copy)
          end

          ctx
        end
      end

    end # SvnBridge
  end # Scm
end # CukeQ
