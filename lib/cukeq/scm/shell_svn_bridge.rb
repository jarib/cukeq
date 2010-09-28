require "open3"
require "nokogiri"

module CukeQ
  class Scm
    class ShellSvnBridge

      def initialize(url, working_copy)
        @url          = url
        @working_copy = working_copy
      end

      def update(&blk)
        ensure_working_copy
        Dir.chdir(@working_copy) { execute "svn update --non-interactive" }

        # TODO: async
        yield
      end

      def current_revision
        ensure_working_copy
        info[:revision]
      end

      private

      def info
        data = {}

        xml = Dir.chdir(@working_copy) { execute "svn --xml info" }
        doc = Nokogiri::XML(xml)

        data[:revision] = doc.css("info entry commit").first['revision'].to_i
        data[:url] = doc.css("url").text

        data
      end

      def ensure_working_copy
        return if File.directory? @working_copy

        log self.class, :checkout, @url.to_s => @working_copy
        execute "svn checkout #{@url} #{@working_copy}"
      end

      def execute(cmd)
        out, err = nil

        Open3.popen3(cmd) do |stdin, stdout, stderr|
          out = stdout.read
          err = stderr.read
        end

        unless $?.success?
          raise SystemCallError, "#{cmd.inspect}, stdout: #{out.inspect}, stderr: #{err.inspect}"
        end

        out
      end
    end # ShellSvnBridge

    SvnBridge = ShellSvnBridge
  end # Scm
end # CukeQ
