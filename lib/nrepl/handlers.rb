module NREPL
  module Handlers
    
    def where_msg msg_id
      Proc.new do |resp|
        resp['id'] && resp['id'] == msg_id
      end
    end
    
    def where_status status
      Proc.new do |resp|
        resp['status'] && resp['status'] == status
      end
    end
    
    # def where_ prop val
    #   Proc.new do |resp|
    #     resp[prop] && resp[prop] == val
    #   end
    # end
    
  end
end
