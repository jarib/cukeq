module CukeQ
  class Runner

    def self.execute(args)
      # FIXME: do this properly
      require "restclient"
      Dir.chdir(args.first) do |dir|
        files = Dir[File.join(dir, "features/**/*.feature")]
        json = files.map { |f| f.gsub(%r[#{dir}/?], '') }.to_json
        RestClient.post("http://localhost:9292/", json, :content_type => "application/json")
      end
    end

  end # Runner
end # CukeQ