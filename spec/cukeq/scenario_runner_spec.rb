require "#{File.dirname(__FILE__)}/../spec_helper"

describe CukeQ::ScenarioRunner do

  def runner
    @runner ||= CukeQ::ScenarioRunner.new
  end

  it "returns an error if the job is incorrect" do
    runner.run({}) do |result|
      result[:success].should be_false
      result[:error].should_not be_empty
      result[:backtrace].should_not be_empty
    end
  end

  it "creates a configured and updated scm instance" do
    job = {'scm' => {'url' => 'git://example.com/foo/bar', 'revision' => 'some-revision'}}

    CukeQ::Scm.should_receive(:new).with(job['scm']['url']).and_return(mock_scm = mock("scm"))
    mock_scm.should_receive(:current_revision).and_return 'another-revision'
    mock_scm.should_receive(:update)

    runner.scm_for(job).should == mock_scm
  end


end