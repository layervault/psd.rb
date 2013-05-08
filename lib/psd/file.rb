class PSD
  class File < ::File
    def read_uint
      read(4).unpack('L>')[0]
    end

    def read_int
      read(4).unpack('l>')[0]
    end

    def read_ushort
      read(2).unpack('S>')[0]
    end

    def read_short
      read(2).unpack('s>')[0]
    end
  end
end