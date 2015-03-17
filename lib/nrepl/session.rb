require 'socket'
require 'bencode'
require 'securerandom'
require 'nrepl/core_ext/securerandom'
require 'nrepl/core_ext/enumerable'
require 'nrepl/core_ext/enumerator_lazy'
require 'nrepl/handlers'

module NREPL
  class Session
    
    attr_reader :responses
    attr_accessor :out
     
    include NREPL::Handlers
      
    def initialize host = '127.0.0.1', port
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
      
    end
    
    def send message
      msg = message.dup
      msg['id'] ||= SecureRandom.uuid
      @conn.write(msg.bencode)
      msg['id']
    end
    
    def recv msg_id
      @responses.lazy.select(&where_id(msg_id))
                     .take_until(&where_status(['done']))
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
      
      handle(raw(opts))
    end
    
    def handle resps
      resps.inject([], &handle_(print_out(@out), select_value))
    end
    
    def close
      @conn.close
    end
    
  end
end
