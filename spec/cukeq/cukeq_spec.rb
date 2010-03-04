require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CukeQ do
  it "identifies this CukeQ instance" do
    Socket.stub!(:gethostname => "hostname")
    Etc.stub!(:getlogin => "login")

    CukeQ.identifier.should == "hostname-login"
  end
end