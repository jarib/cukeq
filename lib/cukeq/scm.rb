module CukeQ
  class Scm
    attr_reader :url

    autoload :GitBridge, "cukeq/scm/git_bridge"
    autoload :SvnBridge, "cukeq/scm/svn_bridge"

    ROOT = File.expand_path("~/.cukeq")

    def initialize(url)
      @url = url.kind_of?(String) ? URI.parse(url) : url
    end

    def working_copy
      @working_copy ||= "#{ROOT}/repos/#{url.host}/#{url.path.gsub(/[^A-z]+/, '_')}"
    end

    def current_revision
      bridge.current_revision
    end

    def update
      log self.class, :updating, url.to_s => working_copy
      bridge.update
      log self.class, :done
    end

    def bridge
      @bridge ||= begin
        case url.scheme
        when "git"
          GitBridge.new url, working_copy
        when "svn"
          SvnBridge.new url, working_copy
        when "http", "https"
         # TODO: fix heuristic for http scm urls
          if url.to_s.include?("svn")
            SvnBridge.new url, working_copy
          elsif url.to_s.include?("git")
            GitBridge.new url, working_copy
          else
            raise "unknown scm: #{url}"
          end
        else
          raise "unknown scm: #{url}"
        end
      end
    end

  end # Scm
end # CukeQ
