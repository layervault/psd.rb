class PSD
  class Util
    def self.pad2(i)
      ((i + 1) / 2) * 2
    end

    def self.pad4(i)
      i - (i.modulo(4)) + 3
    end
  end
end