module NREPL
  module Handlers
    
    def where_id id
      where_('id', id)
    end
    
    def where_status status
      where_('status', status)
    end
    
    def where_ prop, val
      Proc.new do |resp|
        resp[prop] && resp[prop] == val
      end
    end
    
  end
end
