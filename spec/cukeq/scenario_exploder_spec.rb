require "#{File.dirname(__FILE__)}/../spec_helper"

describe CukeQ::ScenarioExploder do

  def exploder
    CukeQ::ScenarioExploder.new
  end

  it "returns the parsed features" do
    # temporary
    units = exploder.explode("features/example1.feature")
    units.first.should == {"file" => "features/example1.feature"}
  end
end