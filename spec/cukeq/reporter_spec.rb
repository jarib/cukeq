require "#{File.dirname(__FILE__)}/../spec_helper"

describe CukeQ::Reporter do

  def reporter
    @reporter ||= CukeQ::Reporter.new(URI.parse("http://example.com/some/path"))
  end

  it "POSTs results to the given URL" do
    expected_params = {
      :host    => "example.com",
      :port    => 80,
      :verb    => 'POST',
      :request => '/some/path',
      :content => '{"some":"result"}'
    }

    EM::P::HttpClient.should_receive(:request).with(expected_params)
    reporter.report("some" => "result")
  end

  it "catches and logs EM errors" do
    reporter.should_receive(:log)
    EM::P::HttpClient.stub!(:request).and_raise(RuntimeError)

    reporter.report(nil)
  end

end