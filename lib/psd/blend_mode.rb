class PSD
  class BlendMode < BinData::Record
    endian  :big

    string  :sig, read_length: 4
    string  :blend_key, read_length: 4, trim_value: true
    uint8   :opacity
    uint8   :clipping
    bit8    :flags
    skip    length: 1

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
      hMix: 'hard mix'
    }

    def mode
      BLEND_MODES[blend_key.to_sym]
    end

    def opacity_percentage
      opacity * 100 / 255
    end

    def transparency_protected
      flags & 0x01
    end

    def visible
      !((flags & (0x01 << 1)) > 0)
    end

    def obsolete
      (flags & (0x01 << 2)) > 0
    end

    def pixel_data_irrelevant
      return nil unless (flags & (0x01 << 3)) > 0
      (flags & (0x01 << 4)) > 0
    end
  end
end