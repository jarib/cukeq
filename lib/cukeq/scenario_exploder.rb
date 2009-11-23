module CukeQ
  class ScenarioExploder

    def explode(file_colon_lines)
      # cwd is now the working copy of the project
      units = []

      # we do the parsing in a subprocess to avoid having to restart the master
      # whenever gherkin/cucumber is updated.
      #
      # The slaves should do the same. CukeQ is just passing things through.
      #
      IO.popen("-") do |pipe|
        if pipe
          while json = pipe.gets
            units << JSON.parse(json)
          end
        else
          file_colon_lines.each do |f|
            puts json_for(f)
          end
        end
      end

      units
    end

    def json_for(file_colon_line)
      # here's where we'll build whatever the ScenarioRunner needs
      # for now though, we'll just do this:
      {:file => file_colon_line}.to_json
    end

  end # ScenarioExploder
end # CukeQ

