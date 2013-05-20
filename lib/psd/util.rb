class PSD
  class Util
    def self.pad2(i)
      ((i + 1) / 2) * 2
    end

    def self.pad4(i)
      i - (i.modulo(4)) + 3
    end

    def self.toUInt16(b1, b2)
      (b1 << 8) | b2
    end

    def self.toInt16(b1, b2)
      num = toUInt16(b1, b2)
      num >= 0x8000 ? num - 0x10000 : num
    end
  end
end