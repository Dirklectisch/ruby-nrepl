# Backport of secure random's UUID generation from: http://softover.com/UUID_in_Ruby_1.8

RUBY_VERSION ||= VERSION

if RUBY_VERSION.split('.').join.to_i < 190 

  module SecureRandom
    class << self
      def method_missing(method_sym, *arguments, &block)
        case method_sym
        when :urlsafe_base64
          r19_urlsafe_base64(*arguments)
        when :uuid
          r19_uuid(*arguments)
        else
          super
        end
      end
    
      private
      def r19_urlsafe_base64(n=nil, padding=false)
        s = [random_bytes(n)].pack("m*")
        s.delete!("\n")
        s.tr!("+/", "-_")
        s.delete!("=") if !padding
        s
      end

      def r19_uuid
        ary = random_bytes(16).unpack("NnnnnN")
        ary[2] = (ary[2] & 0x0fff) | 0x4000
        ary[3] = (ary[3] & 0x3fff) | 0x8000
        "%08x-%04x-%04x-%04x-%04x%08x" % ary
      end
    end
  end
  
end