class PSD
  # Represents the mask for a single layer
  class Mask < BinData::Record
    endian :big

    int32  :mask_size

    int32 :top,           onlyif: :has_data?
    int32 :left,          onlyif: :has_data?
    int32 :bottom,        onlyif: :has_data?
    int32 :right,         onlyif: :has_data?
    int8  :default_color, onlyif: :has_data?
    bit8  :flags,         onlyif: :has_data?

    skip length: 2,   onlyif: lambda { mask_size == 20 }
    skip length: 18,  onlyif: lambda { mask_size > 0 && mask_size != 20}

    # Is there a mask defined?
    def has_data?
      mask_size > 0
    end

    # Width of the mask
    def width
      right - left
    end

    # Height of the mask
    def height
      bottom - top
    end

    def relative
      flags & 0x01
    end

    def disabled
      (flags & (0x01 << 1)) > 0
    end

    def invert
      (flags & (0x01 << 2)) > 0
    end
  end
end