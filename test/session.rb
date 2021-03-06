require 'minitest/spec'
require 'minitest/unit'
require 'minitest/autorun'
require 'nrepl'
require 'stringio'

include NREPL::ResponseHelpers

port = 57519

unless NREPL.port_open?('127.0.0.1', port)
  # Start a nREPL server
  persistent_server = false
  Dir.chdir(File.dirname(__FILE__) + "/fixtures")
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
    resp = @session.recv(msg_id)
    
    resp.first['id'].must_equal(msg_id)
  end
  
  it "sends and receives a multi part message" do
    msg = {
      'op' => 'eval',
      'code' => '(+ 2 3)'
    }

    resps = @session.recv(@session.send(msg))

    resps.count.must_be(:>, 1)
  end

  it "filters response values from the response message stream" do
    vals = @session.eval('(+ 2 3) (+ 4 5)')
    vals.first.must_equal("5")
    vals.last.must_equal("9")
  end

  it "prints output to defined io pipe" do
    string_io = StringIO.new
    @session.out = string_io
    @session.eval('(print "foo") (print "bar")')
    string_io.string.must_equal("foo\nbar\n")
  end

  it "sends and receives multiple messages" do
    msg = {
      'op' => 'describe'
    }

    2.times { @session.send(msg) }
    resps = @session.responses.take(2)

    resps.count.must_be(:==, 2)
    resps.first['id'].wont_equal( resps.last['id'] )
  end

  it 'caches responses' do
    msg = {
      'op' => 'describe'
    }

    3.times { @session.send(msg) }
    resps_one = @session.responses.take(3)
    resps_two = @session.responses.take(3)

    resps_one.must_equal( resps_two )

  end

  it "times out if no response is given within time limit" do
    begin
      @session.responses.with_timeout(0.1).take(1)
    rescue Timeout::Error => e
      e.must_be_instance_of Timeout::Error
    end
  end
  
  it "has a session id" do
    @session.session_id.wont_be_nil
  end
  
  it "is possible to interrupt an eval request" do
    t = Thread.new do
      @session.op(:eval, code: '(Thread/sleep 10000)', session: @session.session_id)
    end
    res = @session.interrupt
    t.join
    res.first['status'].must_equal(["done"])
    
    msg = {
      'op' => 'eval',
      'code' => '(Thread/sleep 10000)',
      'session' => @session.session_id
    }
    msg_id = @session.send(msg)
    ress = @session.interrupt(msg_id)
    ress.first['status'].must_equal(["done"])
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
