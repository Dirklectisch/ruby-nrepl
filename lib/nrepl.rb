require 'nrepl/session'

module NREPL
  
  def self.connect host = '127.0.0.1', port
    Session.new host, port
  end
  
  def self.start port = nil, host = nil
    # Start a new nREPL process
    cmd = %x[which lein].rstrip || '/usr/local/bin/lein'
    argv = []
    argv << 'trampoline' if File.exist?('project.clj')
    argv += ['repl', ':headless']
    argv << " :host #{host}" if host
    argv << " :port #{port}" if port
    
    pid = fork do
      exec cmd, *argv
    end
    
    Process.setpgid(pid, pid)     
    pid
  end
  
  def self.stop gid
    unless gid == 0
      Process.kill('SIGTERM', -gid)
    end
  end
  
end