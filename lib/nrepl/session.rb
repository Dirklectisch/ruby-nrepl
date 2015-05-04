require 'socket'
require 'bencode'
require 'securerandom'
require 'nrepl/core_ext/securerandom'
require 'nrepl/core_ext/enumerable'
require 'nrepl/core_ext/enumerator_lazy'
require 'nrepl/response_helpers'

module NREPL
  
  class Session
    
    attr_reader :responses, :session_id
    attr_accessor :out
     
    include NREPL::ResponseHelpers
      
    def initialize host = '127.0.0.1', port
      @host = host
      @port = port
      @conn = TCPSocket.new host, port
      @parser = BEncode::Parser.new(@conn)
      @out = $stdout
      
      # Create a lazy enumerator that caches responses
      cache = []
      @responses = Enumerator.new do |y|
        head = 0
        while head < cache.count
          y << cache[head]
          head += 1
        end
        while msg =  @parser.parse!
          cache << msg
          y << msg
        end
      end
      
      # Clone a new session to aquire a session_id
      @session_id = self.op(:clone)
                        .select(&has_('new-session'))
                        .first['new-session']
      
    end
    
    def send message
      msg = message.dup
      msg['id'] ||= SecureRandom.uuid
      @conn.write(msg.bencode)
      msg['id']
    end
    
    def recv msg_id
      @responses.lazy.select(&where_id(msg_id))
                     .take_until(&is_done)
    end
    
    def raw message
      recv(send(message))
    end
    
    def op name, opts = {}
      
      # Convert keyword keys to strings
      opts.keys.each do |key|
        opts[key.to_s] = opts.delete(key)
      end
      
      opts['op'] = name.to_s
      
      raw(opts)
    end
    
    def eval code
      resps = op(:eval, code: code, session: session_id).force
      resps.map(&print_out(@out))
      vals = resps.select(&has_value).map(&select_value)
      vals.size == 1 ? vals.first : vals
    end
    
    # TODO: Prevent blocking on interruption error
    def interrupt msg_id = nil
      new_session = NREPL::Session.new(@host, @port)
      unless msg_id
        res = new_session.op(:interrupt, session: session_id).force
      else
        res = new_session.op(:interrupt, { :session => session_id, :"interrupt-id" => msg_id }).force
      end
      new_session.close
      res
    end
    
    def close
      op(:close, session: session_id)
      @conn.close
    end
    
  end
end
