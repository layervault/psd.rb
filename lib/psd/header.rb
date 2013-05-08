class PSD
  class Header < BinData::Record
    endian :big

    string  :sig, read_length: 4
    uint16  :version

    # Reserved bytes
    skip    length: 6

    uint16  :channels
    uint32  :rows
    uint32  :cols
    uint16  :depth
    uint16  :mode

    uint32  :color_data_len
    skip    length: :color_data_len

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
    ]

    def mode_name
      if mode >= 0 && mode <= 15
        MODES[mode]
      else
        "(#{mode})"
      end
    end
  end
end