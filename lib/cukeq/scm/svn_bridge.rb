require "svn/client" # apt-get install libsvn-ruby

module CukeQ
  class Scm
    class SvnBridge

      def initialize(url, working_copy)
        @url          = url
        @working_copy = working_copy

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
        user = ENV['CUKEQ_SVN_USERNAME'] || @url.user
        return user if user

        auth = Svn::Core::Config.read_auth_data(Svn::Core::AUTH_CRED_SIMPLE, realm)
        raise_auth_error unless auth

        auth["username"]
      end

      def find_password(realm)
        pass = ENV['CUKEQ_SVN_PASSWORD'] || @url.password
        return pass if pass

        auth = Svn::Core::Config.read_auth_data(Svn::Core::AUTH_CRED_SIMPLE, realm)
        raise_auth_error unless auth

        auth["password"]
      end

      def raise_auth_error
        raise <<-END
         no svn authorization provided. try:
            * set CUKEQ_SVN_USERNAME and CUKEQ_SVN_PASSWORD
            * add username and password to the repo URL: https://foo:bar@svn.example.com/
            * make sure correct simple auth is provided in ~/.subversion
         END
      end

      def ensure_working_copy
        unless File.directory? @working_copy
          log self.class, :checkout, @url.to_s => @working_copy
          ctx.checkout(@url.to_s, @working_copy)
        end
      end

    end # SvnBridge
  end # Scm
end # CukeQ
