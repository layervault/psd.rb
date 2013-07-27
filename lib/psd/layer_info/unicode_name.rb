require_relative '../layer_info'

class PSD
  class UnicodeName < LayerInfo
    @key = 'luni'

    def parse
      pos = @file.tell
      len = @file.read_int * 2
      @data = @file.read(len).unpack("A#{len}")[0].encode('UTF-8').delete("\000")

      # The name seems to be padded with null bytes. This is the easiest solution.
      @file.seek pos + @length

      return self
    end
  end
end