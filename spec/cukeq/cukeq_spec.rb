require File.expand_path("../../spec_helper", __FILE__)

describe CukeQ do
  it "identifies this CukeQ instance" do
    Socket.stub!(:gethostname => "hostname")
    Etc.stub!(:getlogin => "login")

    CukeQ.identifier.should == "hostname-login"
  end
end