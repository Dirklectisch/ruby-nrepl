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
     
    include NREPL::Handlers
      
    def initialize host = '127.0.0.1', port
      @conn = TCPSocket.new host, port
      @parser = BEncode::Parser.new(@conn)
      
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
      @responses.lazy.select(&where_id(msg_id)).take_until(&where_status(['done']))
    end
    
    def last_response msg_id
      Proc.new do |resp|
        resp['status'] && resp['id'] == msg_id && resp['status'] == ['done']
      end
    end
    
    def close
      @conn.close
    end
    
  end
end
