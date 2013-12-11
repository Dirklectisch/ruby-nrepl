require 'minitest/spec'
require 'minitest/autorun'
require 'nrepl'

describe NREPL do
  
  it "starts and stops a local server" do
    # Start a new nREPL server
    pid = NREPL.start(57519)
    
    # Wait for nREPL server to start
    pid_waiter = NREPL.wait_until_ready(pid)
    pid_waiter.alive?.must_equal(true)
    pid_waiter.status.must_equal('sleep') # Hopefully ready for IO
    
    #TODO: Test connection
    
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
end
