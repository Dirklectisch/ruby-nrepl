module NREPL
  module Handlers
    
    def handle_ *handlers
      Proc.new do |memo, resp|
        hs = handlers.dup
        res = hs.pop.call(resp)
        memo << res if res
        hs.each do |handler|
          handler.call(resp)
        end
        memo
      end
    end
    
    def print_out io_out
      Proc.new do |resp|
        output = select_out.call(resp)
        io_out.puts(output) if output
      end
    end
    
    def select_value
      select_('value')
    end
    
    def select_out
      select_('out')
    end
    
    def select_ prop
      Proc.new do |resp|
        if resp[prop]
          resp[prop]
        else
          nil
        end
      end
    end
    
    # Predicates
    
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
