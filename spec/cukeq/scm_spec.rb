require File.expand_path("../../spec_helper", __FILE__)

describe CukeQ::Scm do

  def scm(vcs, mock_bridge = false)
    scm = case vcs
          when :git
            CukeQ::Scm.new("git://github.com/jarib/cukeq.git")
          when :svn
            CukeQ::Scm.new("svn://example.com/somerepo/trunk")
          else
            raise "unknown vcs: #{vcs.inspect}"
          end

    if mock_bridge
      scm.instance_variable_set("@bridge", mock("scm-bridge"))
    end

    scm
  end

  it "replaces special characters in the working copy dir" do
    scm(:git).working_copy.should !~ /[^A-z]/
  end

  it "creates the correct bridge" do
    scm(:git).bridge.should be_kind_of(CukeQ::Scm::GitBridge)
    scm(:svn).bridge.should be_kind_of(CukeQ::Scm::SvnBridge)
  end

  it "understands http urls" do
    CukeQ::Scm.new("http://github.com/foo/bar.git").bridge.should be_kind_of(CukeQ::Scm::GitBridge)
    CukeQ::Scm.new("https://svn.example.com/foo/bar").bridge.should be_kind_of(CukeQ::Scm::SvnBridge)
  end

  it "forwards update() to the bridge" do
    scm = scm(:git, true)
    scm.bridge.should_receive(:update).and_yield
    scm.update {}
  end

  it "forwards current_revision() to the bridge" do
    scm = scm(:git, true)
    scm.bridge.should_receive(:current_revision)
    scm.current_revision
  end

end