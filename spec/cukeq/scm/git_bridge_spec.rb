require File.expand_path("../../../spec_helper", __FILE__)

describe CukeQ::Scm::GitBridge do
  include FileUtils

  GIT_URL = "git://example.com"
  WORKING_COPY = "spec-scm-repo"

  after(:each) do
    rm_rf WORKING_COPY
  end

  def mock_repo
    @mock_repo ||= mock("Git::Base", :null_object => true)
  end

  def bridge
    @bridge ||= CukeQ::Scm::GitBridge.new(GIT_URL, WORKING_COPY)
  end

  it "clones the repo of it doesn't exist" do
    Git.stub!(:open)
    Git.should_receive(:clone).with(GIT_URL, WORKING_COPY)
    bridge.repo
  end

  it "does not clone the repo if it already exists" do
    Git.stub!(:open)
    Git.should_receive(:clone).never

    mkdir WORKING_COPY
    bridge.repo
  end

  it "fetches the current revision" do
    bridge.stub!(:repo).and_return(mock_repo)
    mock_repo.should_receive(:revparse).with("HEAD").and_return("rev")

    bridge.current_revision.should == "rev"
  end

  it "updates the working copy" do
    bridge.stub!(:repo).and_return(mock_repo)

    mock_repo.should_receive(:reset_hard)
    mock_repo.should_receive(:pull)

    bridge.update {}
  end


end