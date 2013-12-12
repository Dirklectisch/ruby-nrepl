require 'minitest/spec'
require 'minitest/unit'
require 'minitest/autorun'
require 'nrepl'

port = 57519

unless NREPL.port_open?('127.0.0.1', port)
  # Start a nREPL server
  persistent_server = false
  pid = NREPL.start(port)
  pid_waiter = NREPL.wait_until_ready(pid)
else
  persistent_server = true
end

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
    resps = @session.responses.take_until(&@session.last_response(msg_id))
    resps.count.must_be(:>, 1)
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
    begin
      @session.responses.with_timeout(0.1).take(1)
    rescue Timeout::Error => e
      e.must_be_instance_of Timeout::Error
    end
  end
  
  it "does not times out if no response is within time limit" do
    msg = {
      'op' => 'describe'
    }
    
    msg_id = @session.send(msg)
    resp = @session.responses.with_timeout(5).take(1)
    
    resp.first['id'].must_equal(msg_id)
  end
  
  after do
    @session.close
  end
end

MiniTest::Unit.after_tests do
  unless persistent_server == true
    # Stop nREPL server
    NREPL.stop(pid)
    pid_waiter.join
  end
end
