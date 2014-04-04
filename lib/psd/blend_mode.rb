class PSD
  class BlendMode
    attr_reader :blend_key, :opacity, :clipping

    # All of the blend modes are stored in the PSD file with a specific key.
    # This is the mapping of that key to its readable name.
    BLEND_MODES = {
      norm: 'normal',
      dark: 'darken',
      lite: 'lighten',
      hue:  'hue',
      sat:  'saturation',
      colr: 'color',
      lum:  'luminosity',
      mul:  'multiply',
      scrn: 'screen',
      diss: 'dissolve',
      over: 'overlay',
      hLit: 'hard light',
      sLit: 'soft light',
      diff: 'difference',
      smud: 'exclusion',
      div:  'color dodge',
      idiv: 'color burn',
      lbrn: 'linear burn',
      lddg: 'linear dodge',
      vLit: 'vivid light',
      lLit: 'linear light',
      pLit: 'pin light',
      hMix: 'hard mix',
      pass: 'passthru',
      dkCl: 'darker color',
      lgCl: 'lighter color',
      fsub: 'subtract',
      fdiv: 'divide'
    }.freeze

    def initialize(file)
      @file = file
      
      @blend_key = nil
      @opacity = nil
      @clipping = nil
      @flags = nil
    end

    def parse!
      @file.seek 4, IO::SEEK_CUR

      @blend_key = @file.read_string(4).strip
      @opacity = @file.read_byte
      @clipping = @file.read_byte
      @flags = @file.read_byte

      @file.seek 1, IO::SEEK_CUR
    end

    def mode
      BLEND_MODES[@blend_key.to_sym]
    end
    alias_method :blending_mode, :mode

    def opacity_percentage
      @opacity_percentage ||= @opacity * 100 / 255
    end

    def clipped?
      @clipping == 1
    end

    def transparency_protected
      @flags & 0x01
    end

    def visible
      !((@flags & (0x01 << 1)) > 0)
    end

    def obsolete
      (@flags & (0x01 << 2)) > 0
    end

    def pixel_data_irrelevant
      return nil unless (@flags & (0x01 << 3)) > 0
      (@flags & (0x01 << 4)) > 0
    end
  end
end