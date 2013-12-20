require 'timeout'

module Enumerable
  def take_until
    if block_given?
      ary = []
      while n = self.next
        ary << n
        if (yield n) == true
          return ary 
        end
      end
    else
      return self
    end
  end
  
  def with_timeout seconds = nil
    if seconds && block_given?
      while n = Timeout::timeout(seconds) { self.next }
        yield n
      end
    elsif seconds
      Enumerator.new { |y|
        while n = Timeout::timeout(seconds) { self.next }
          y << n
        end
      }      
    else  
      return self
    end
  end
end
