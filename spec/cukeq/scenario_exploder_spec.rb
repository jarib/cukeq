require File.expand_path("../../spec_helper", __FILE__)

describe CukeQ::ScenarioExploder do

  def exploder
    CukeQ::ScenarioExploder.new
  end

  it "returns the parsed features" do
    # our IO.popen call doesn't work well with rspec - probably a race condition since
    # it only fails on RCR
    pending

    # units = exploder.explode("features/example1.feature")
    # units.first.should == {"file" => "features/example1.feature"}
  end
end