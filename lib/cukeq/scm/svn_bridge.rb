require "svn/client" # apt-get install libsvn-ruby

module CukeQ
  class Scm
    class SvnBridge

      def initialize(url, working_copy)
        @url          = url
        @working_copy = working_copy

        @simple_auth = Hash.new do |hash, realm|
          hash[realm] = simple_auth_for(realm) || raise_auth_error
        end

        setup_auth
      end

      def update
        ensure_working_copy
        ctx.update(@working_copy).to_s
      end

      def current_revision
        ensure_working_copy

        Dir.chdir(@working_copy) do
          ctx.status(@working_copy, "BASE").to_s
        end
      end

      private

      def ctx
        @ctx ||= Svn::Client::Context.new
      end

      def setup_auth
        ctx.add_simple_prompt_provider(0) do |cred, realm, username, save|
          cred.username = ENV['CUKEQ_SVN_USERNAME'] || @url.user || @simple_auth[realm]["username"]
          cred.password = ENV['CUKEQ_SVN_PASSWORD'] || @url.password || @simple_auth[realm]["password"]
          cred
        end

        if ENV['CUKEQ_SVN_INSECURE_SSL']
          ctx.add_ssl_server_trust_prompt_provider do |cred, host, failures, info, was|
            cred.accepted_failures = failures
            cred
          end
        end
      end

      def simple_auth_for(realm)
        Svn::Core::Config.read_auth_data(Svn::Core::AUTH_CRED_SIMPLE, realm)
      end

      def raise_auth_error
        raise <<-END
         No SVN credentials provided. Either of these will do:
            * set CUKEQ_SVN_USERNAME and CUKEQ_SVN_PASSWORD
            * add username and password to the repo URL: https://foo:bar@svn.example.com/
            * make sure your credentials are saved to disk (~/.subversion/auth)
         END
      end

      def ensure_working_copy
        return if File.directory? @working_copy

        log self.class, :checkout, @url.to_s => @working_copy
        ctx.checkout(@url.to_s, @working_copy)
      end

    end # SvnBridge
  end # Scm
end # CukeQ
