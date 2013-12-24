class Enumerator::Lazy
  def take_until
    if block_given?
      ary = []
      while n = self.next
        ary << n
        if (yield n) == true
          break
        end
      end
      return ary.lazy
    else
      return self
    end
  end
end
