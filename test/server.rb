require 'minitest/spec'
require 'minitest/autorun'
require 'nrepl'

describe NREPL do
  
  # it "starts, connects, disconnects and stops an nrepl server/session" do
  #   session = NREPL.start_and_connect(57519)
  #   NREPL.disconnect_and_stop(session).must_equal(true)
  # end
  
  it "waits for the local server to start and stop" do
    # Start a new nREPL server
    pid = NREPL.start(57519)
    
    # Wait for nREPL server to start
    pid_waiter = NREPL.wait_until_ready(pid)
    pid_waiter.alive?.must_equal(true)
    pid_waiter.status.must_equal('sleep') # Hopefully ready for IO
    
    NREPL.stop(pid)
    
    # Wait for nREPL to stop
    pid_waiter.join 
    pid_waiter.alive?.must_equal(false)
  end
  
  it "throws an error when waiting for an invalid process" do
    
    pid = 57519
    
    begin
      NREPL.wait_until_ready(pid)
    rescue => e
      e.must_be_instance_of RuntimeError
    end
  end
  
  it "checks if the remote port is open" do
    
    port = 57519
    begin
      NREPL.port_open?('127.0.0.1', port)
    rescue => e
      e.must_be_instance_of Errno::ECONNREFUSED
    end
    
  end
  
  it "waits until port is available for connection" do
    
    pid = NREPL.start(57519)
    pid_waiter = NREPL.wait_until_ready(pid)
    NREPL.wait_until_available(57519, 10).must_equal(true)
    NREPL.stop(pid)
    pid_waiter.join 
    
  end

end
