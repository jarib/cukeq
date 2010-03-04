require "#{File.dirname(__FILE__)}/../spec_helper"

describe CukeQ::Broker do
  def queues
    @queues ||= {
      :results => mock("results-queue"),
      :jobs    => mock("jobs-queue")
    }
  end

  def running_broker
    broker = CukeQ::Broker.new(URI.parse("amqp://cukeq-master@localhost:1234/cukeq"))
    broker.instance_variable_set("@queues", queues)

    broker
  end

  describe "#start" do
    it "starts AMQP with the given broker config" do
      broker = CukeQ::Broker.new(URI.parse("amqp://cukeq-master@localhost:1234/cukeq"))

      expected_params = {
        :host => 'localhost',
        :port => 1234,
        :vhost => "/cukeq",
        :user => 'cukeq-master'
      }

      AMQP.should_receive(:start).with(hash_including(expected_params)).and_yield

      mock_q = mock("queue")
      MQ.should_receive(:new).twice.and_return(mock_q)
      mock_q.should_receive(:queue).twice

      broker.start
    end
  end

  it "should publish messages on the given queue" do
    broker = running_broker
    message = "some message"

    queues.each do |name, queue|
      queue.should_receive(:publish).with(message)
      broker.publish(name, message)
    end
  end

  it "should subscribe/unsubscribe from the given queue" do
    EM.stub(:add_periodic_timer)
    broker = running_broker

    # TODO: this looks pretty stupid, could we just expose the queues directly?
    queues[:results].should_receive(:pop)
    broker.subscribe(:results) {}
  end

  describe "#queue_for" do
    it "should return the right queue" do
      broker = running_broker
      broker.queue_for(:results).should == queues[:results]
      broker.queue_for(:jobs).should == queues[:jobs]
    end

    it "raises an error if the queue is not found" do
      broker = running_broker
      lambda { broker.queue_for(:foo) }.should raise_error
    end
  end


end