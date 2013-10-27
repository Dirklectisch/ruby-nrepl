require 'minitest/spec'
require 'minitest/autorun'
require 'nrepl'

describe NREPL do
  
  it "starts and stops a local server" do
    pid = NREPL.start 57519
    
    # Wait for nREPL to start
    pid_waiter = Thread.new { Process.wait(pid) }
    sleep(1) until pid_waiter.status == 'sleep'
    pid_waiter.alive?.must_equal(true)
    pid_waiter.status.must_equal('sleep') # Hopefully ready for IO
    
    #TODO: Test connection
    # session = NREPL.connect 57519
    # msg = {
    #   'op' => 'describe'
    # }
    # msg_id = @session.send(msg)
    # puts msg_id
    
    NREPL.stop(pid)
    
    # Wait for nREPL to stop
    pid_waiter.join 
    pid_waiter.alive?.must_equal(false)
  end
  
end