require "svn/client" # apt-get install libsvn-ruby

module CukeQ
  class Scm
    class SvnBridge

      def initialize(url, working_copy)
        @url          = url
        @working_copy = working_copy

        @simple_auth_data = {}
        setup_auth
      end

      def update
        ensure_working_copy
        ctx.update(@working_copy).to_s
      end

      def current_revision
        ensure_working_copy
        ctx.status(@working_copy).to_s
      end

      private

      def ctx
        @ctx ||= Svn::Client::Context.new
      end

      def setup_auth
        ctx.add_simple_prompt_provider(0) do |cred, realm, username, save|
          cred.username = find_username(realm)
          cred.password = find_password(realm)
          cred
        end

        if ENV['CUKEQ_SVN_INSECURE_SSL']
          ctx.add_ssl_server_trust_prompt_provider do |cred, host, failures, info, was|
            cred.accepted_failures = failures
            cred
          end
        end
      end

      def find_username(realm)
        ENV['CUKEQ_SVN_USERNAME'] || @url.user || simple_auth_data_for(realm)["username"]
      end

      def find_password(realm)
        ENV['CUKEQ_SVN_PASSWORD'] || @url.password || simple_auth_data_for(realm)["password"]
      end

      def simple_auth_data_for(realm)
        data = @simple_auth_data_for[realm] ||= Svn::Core::Config.read_auth_data(Svn::Core::AUTH_CRED_SIMPLE, realm)
        raise_auth_error if data.nil?

        data
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
