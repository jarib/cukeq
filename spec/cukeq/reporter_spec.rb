require "#{File.dirname(__FILE__)}/../spec_helper"

describe CukeQ::Reporter do

  it "POSTs results to the given URL" do
    reporter = CukeQ::Reporter.new(URI.parse("http://example.com/some/path"))

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

end