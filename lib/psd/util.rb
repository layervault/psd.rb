class PSD
  class Util
    # Ensures value is a multiple of 2
    def self.pad2(i)
      (i + 1) & ~0x01
    end

    # Ensures value is a multiple of 4
    def self.pad4(i)
      ((i + 4) & ~0x03) - 1
    end

    def self.clamp(num, min, max)
      [min, num, max].sort[1]
    end
  end
end