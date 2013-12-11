require 'socket'
require 'bencode'
require 'securerandom'
require 'nrepl/core_ext/securerandom'
require 'nrepl/core_ext/enumerable'
require 'timeout'

module NREPL
  class Session
    
    attr_reader :responses
    attr_accessor :handlers
    attr_accessor :timeout
      
    def initialize host = '127.0.0.1', port
      @conn = TCPSocket.new host, port
      @parser = BEncode::Parser.new(@conn)
      @timeout = 5 # Seconds
      @responses = Enumerator.new { |y|
        while msg =  Timeout::timeout(@timeout) { @parser.parse! }
          y << msg
        end
      }
    end
    
    def send message
      msg = message.dup
      msg['id'] ||= SecureRandom.uuid
      @conn.write(msg.bencode)
      msg['id']
    end
    
    def last_response? resp, msg_id
      resp['status'] && resp['id'] == msg_id && resp['status'] == ['done']
    end
    
    def close
      @conn.close
    end
    
  end
end
