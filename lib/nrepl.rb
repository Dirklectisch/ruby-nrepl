require 'nrepl/session'

module NREPL
  
  def self.connect host = '127.0.0.1', port
    Session.new host, port
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