require File.expand_path("../../spec_helper", __FILE__)

describe CukeQ do
  it "identifies this CukeQ instance" do
    Socket.stub!(:gethostname => "hostname")
    Etc.stub!(:getlogin => "login")
    Process.stub!(:pid => "pid")

    CukeQ.identifier.should == "hostname-login-pid"
  end
end