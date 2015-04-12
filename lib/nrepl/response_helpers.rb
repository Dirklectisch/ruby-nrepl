module NREPL
  module ResponseHelpers
  
    # def handle_ *handlers
    #   Proc.new do |memo, resp|
    #     hs = handlers.dup
    #     res = hs.pop.call(resp)
    #     memo << res if res
    #     hs.each do |handler|
    #       handler.call(resp)
    #     end
    #     memo
    #   end
    # end
    
    def print_out io_out
      Proc.new do |resp|
        output = select_out.call(resp)
        io_out.puts(output) if output
      end
    end
    
    # Property filters
    
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
    
    def has_ prop
      Proc.new do |resp|
        resp.keys.include?(prop)
      end
    end
    
    def has_status
      has_('status')
    end
    
    def has_value
      has_('value')
    end
    
    def includes_status status
      Proc.new do |resp|
        has_status.call(resp) && resp['status'].include?(status)
      end
    end
    
    def where_ prop, val
      Proc.new do |resp|
        has_(prop).call(resp) && resp[prop] == val
      end
    end
    
    def where_id id
      where_('id', id)
    end
    
    def is_done
      Proc.new do |resp|
        includes_status('done').call(resp) || includes_status('error').call(resp)
      end
    end
    
  end
end
