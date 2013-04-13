class String
  if RUBY_VERSION >= "1.9"
    def xor_impl(other)
      result = "".encode("ASCII-8BIT")
      o_bytes = other.bytes.to_a
      bytes.each_with_index do |c, i|
        result << (c ^ o_bytes[i])
      end
      result
    end
  else
    def xor_impl(other)
      result = (0..self.length-1).collect { |i| self[i] ^ other[i] }
      result.pack("C*")
    end
  end
end
