class PSD
  class File < ::File
    def read_uint
      read(4).unpack('L>')[0]
    end
    alias_method :read_ushort, :read_uint

    def read_int
      read(4).unpack('l>')[0]
    end
    alias_method :read_short, :read_int
  end
end