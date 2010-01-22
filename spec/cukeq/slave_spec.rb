require "#{File.dirname(__FILE__)}/../spec_helper"

describe CukeQ::Slave do

  def mock_slave
    CukeQ::Slave.new(
      mock("CukeQ::Broker", :null_object => true),
      mock("CukeQ::ScenarioRunner", :null_object => true)
    )
  end

  def running_slave
    slave = mock_slave
    slave.broker.stub!(:start).and_yield

    slave
  end

  describe ".configured_instance" do
    it "sets up defaults if --broker is not given" do
      slave = CukeQ::Slave.configured_instance

      slave.broker.host.should == 'localhost'
      slave.broker.port.should == 5672
      slave.broker.user.should == 'cukeq-slave'
      slave.broker.pass.should == 'cukeq123'
      slave.broker.vhost.should == '/cukeq'
    end

    it "adds defaults if the --broker argument is incomplete" do
      slave = CukeQ::Slave.configured_instance(%w[--broker amqp://otherhost:9000])

      slave.broker.host.should == 'otherhost'
      slave.broker.port.should == 9000
      slave.broker.user.should == 'cukeq-slave'
      slave.broker.pass.should == 'cukeq123'
      slave.broker.vhost.should == '/cukeq'
    end
  end

  describe ".execute" do
    it "starts the configured instance" do
      args   = %w[some args]
      slave = mock_slave

      CukeQ::Slave.should_receive(:configured_instance).with(args).and_return(slave)
      slave.should_receive(:start)

      CukeQ::Slave.execute(args)
    end
  end

  describe "#start" do
    it "subscribes to the jobs queue" do
      slave = mock_slave
      slave.broker.should_receive(:start).and_yield
      slave.should_receive(:subscribe)

      slave.start
    end
  end

  describe "#job" do
    it "runs each job with the scenario runner and publishes each result on the results queue" do
      slave = running_slave
      job   = {:some => 'job'}
      result = {:some => 'result'}

      slave.scenario_runner.should_receive(:run).with(job).and_yield(result)
      slave.should_receive(:publish).with(result)

      slave.job(job)
    end
  end

  describe "#publish" do
    it "it publishes the message on the results queue" do
      slave = running_slave
      message = "some message"

      slave.broker.should_receive(:publish).with(:results, message.to_json)
      slave.publish(message)
    end
  end

  describe "#subscribe" do
    it "should subscribe to the jobs queue and process the messages" do
      slave = running_slave
      slave.broker.should_receive(:subscribe).with(:jobs).and_yield('{"some": "job"}')
      slave.should_receive(:job).with('some' => 'job')

      slave.subscribe
    end
  end

end