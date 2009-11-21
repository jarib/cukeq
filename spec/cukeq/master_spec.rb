require "#{File.dirname(__FILE__)}/../spec_helper"

describe CukeQ::Master do
  describe ".parse" do
    def parse(argv)
      CukeQ::Master.send :parse, argv
    end

    it "parses the --broker argument given host:port" do
      opts = parse %w[--broker somehost:1234]

      opts[:broker_host].should == 'somehost'
      opts[:broker_port].should == 1234
    end

    it "parses the --broker argument given just host" do
      opts = parse %w[--broker somehost]

      opts[:broker_host].should == 'somehost'
      opts[:broker_port].should == 5672
    end

    it "parses the --scm argument" do
      opts = parse %w[--scm git://github.com/foo/bar.git]

      opts[:scm].should be_kind_of(CukeQ::Scm)
      opts[:scm].url.should == "git://github.com/foo/bar.git"
    end

    it "parses the --report-to argument" do
      opts = parse %w[--report-to http://localhost:1234/foo/bar]

      opts[:report_to].should be_kind_of(CukeQ::Reporter)
      opts[:report_to].url.should == "http://localhost:1234/foo/bar"
    end
  end

  describe ".execute" do
    it "creates and runs a configured Master" do
      CukeQ::Master.should_receive(:new).with do |broker_host, broker_port, scm, reporter|
        broker_host.should == 'somehost'
        broker_port.should == 1234

        scm.should be_kind_of(CukeQ::Scm)
        scm.url.should == "git://github.com/foo/bar.git"

        reporter.should be_kind_of(CukeQ::Reporter)
        reporter.url.should == "http://localhost:1234/foo/bar"
      end.and_return(mock_master = mock('Master'))

      mock_master.should_receive(:run)

      CukeQ::Master.execute %w[--broker somehost:1234 --scm git://github.com/foo/bar.git --report-to http://localhost:1234/foo/bar]
    end
  end


end