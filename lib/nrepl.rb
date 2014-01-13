require 'nrepl/session'
require 'nrepl/handlers'
require 'socket'
require 'timeout'

module NREPL
  
  DEFAULT_CONNECTION_TIMEOUT = 10
  
  def self.start_and_connect host = '127.0.0.1', port
    pid = start(host, port)
    wait_until_ready(pid)
    wait_until_available(host, port, DEFAULT_CONNECTION_TIMEOUT)
    session = connect(host, port)
    
    set_pid_msg = {
      'op' => 'eval',
      'code' => "(def user/lein-gid #{pid})"
    }
    session.op(set_pid_msg)
    
    # TODO: Implement some kind of clearing mechanism
    #session.clear! 
    session
  end
  
  def self.disconnect_and_stop session
    
    get_pid_msg = {
      'op' => 'eval',
      'code' => "user/lein-gid"
    }
    
    resp = session.op(get_pid_msg)
    session.close
    stop(resp.first.to_i)
    true
  end
  
  def self.connect host = '127.0.0.1', port
    Session.new host, port
  end
  
  def self.wait_until_available host = '127.0.0.1', port, seconds
    Timeout::timeout(seconds) do
      sleep(1) until port_open? host, port
      return true
    end
    return false
  end
  
  def self.port_open? host, port
    begin
      TCPSocket.new(host, port).close
      true
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
      false
    end
  end
  
  def self.start host = '127.0.0.1', port
    # Start a new nREPL process
    cmd = %x[which lein].rstrip || '/usr/local/bin/lein'
    argv = []
    argv << 'trampoline' if File.exist?('project.clj')
    argv += ['repl', ':headless']
    argv += [':host', host.to_s] if host
    argv += [':port', port.to_s] if port
    
    pid = fork do
      exec cmd, *argv
    end
    
    Process.setpgid(pid, pid)     
    pid
  end
  
  def self.wait_until_ready pid
    pid_waiter = Thread.new { Process.wait(pid) }
    sleep(1) while pid_waiter.status == 'run'
    if pid_waiter.status == 'sleep'
      return pid_waiter
    else
      raise "Process #{pid} killed, crashed or aborted."
    end
  end
  
  def self.stop gid
    unless gid == 0
      Process.kill('SIGTERM', -gid)
    end
  end
  
end
