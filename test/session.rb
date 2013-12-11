require 'minitest/spec'
require 'minitest/unit'
require 'minitest/autorun'
require 'nrepl'

# Start NREPL server
port = 57519
pid = NREPL.start(57519)
pid_waiter = NREPL.wait_until_ready(pid)

describe NREPL::Session do
  before do
    NREPL.wait_until_available(port, NREPL::DEFAULT_CONNECTION_TIMEOUT)
    @session = NREPL::Session.new(port)
  end
  
  it "sends and receives a single message" do
    msg = {
      'op' => 'describe'
    }
    
    msg_id = @session.send(msg)
    resp = @session.responses.next
    
    resp['id'].must_equal(msg_id)
  end
  
  it "sends and receives a multi part message" do
    msg = {
      'op' => 'eval',
      'code' => '(+ 2 3)'
    }
    
    msg_id = @session.send(msg)
    resps = @session.responses.take_until do |resp| 
      @session.last_response?(resp, msg_id)
    end
    
    resps.count.must_be(:>, 0)
  end
  
  it "it sends and receives multiple messages" do
    msg = {
      'op' => 'describe'
    }
    
    2.times { @session.send(msg) }
    resps = @session.responses.take(2)
    
    resps.count.must_be(:==, 2)
    resps.first['id'].wont_equal( resps.last['id'] )
  end
  
  it "times out if no response is given within time limit" do
    @session.timeout = 0.1
    begin
      @session.responses.take(1)
    rescue Timeout::Error => e
      e.must_be_instance_of Timeout::Error
    end
    @session.timeout = 5
  end
  
  after do
    @session.close
  end
end

MiniTest::Unit.after_tests do
  # Stop nREPL server
  NREPL.stop(pid)
  pid_waiter.join
end