class PSD
  class Header
    attr_reader :sig, :version, :channels, :rows, :cols, :depth, :mode

    # All of the color modes are stored internally as a short from 0-15.
    # This is a mapping of that value to a human-readable name.
    MODES = [
      'Bitmap',
      'GrayScale',
      'IndexedColor',
      'RGBColor',
      'CMYKColor',
      'HSLColor',
      'HSBColor',
      'Multichannel',
      'Duotone',
      'LabColor',
      'Gray16',
      'RGB48',
      'Lab48',
      'CMYK64',
      'DeepMultichannel',
      'Duotone16'
    ].freeze

    alias_method :width, :cols
    alias_method :height, :rows

    def initialize(file)
      @file = file

      @sig = nil
      @version = nil
      @channels = nil
      @rows = nil
      @cols = nil
      @depth = nil
      @mode = nil
    end

    def parse!
      @sig = @file.read_string(4)
      @version = @file.read_ushort

      # Reserved bytes, must be 0
      @file.seek 6, IO::SEEK_CUR

      @channels = @file.read_ushort
      @rows = @file.read_uint
      @cols = @file.read_uint
      @depth = @file.read_ushort
      @mode = @file.read_ushort

      color_data_len = @file.read_uint
      @file.seek color_data_len, IO::SEEK_CUR
    end

    def mode_name
      MODES[@mode]
    end

    def big?
      version == 2
    end

    def rgb?
      mode == 3
    end

    def cmyk?
      mode == 4
    end
  end
end
