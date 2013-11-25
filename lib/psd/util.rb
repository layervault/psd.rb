class PSD
  module Util
    extend self

    # Ensures value is a multiple of 2
    def pad2(i)
      ((i + 1) / 2) * 2
    end

    # Ensures value is a multiple of 4
    def pad4(i)
      i - (i.modulo(4)) + 3
    end

    def clamp(num, min, max)
      [min, num, max].sort[1]
    end
  end
end