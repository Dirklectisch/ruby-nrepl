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
end
