require 'psd/layer_info'

class PSD
  # This is the new way that Photoshop stores the brightness/contrast
  # data. If this data is present, DO NOT use the legacy BrightnessContrast
  # info block.
  class ContentGenerator < LayerInfo
    def self.should_parse?(key)
      key == 'CgEd'
    end

    def parse
      # Version
      @file.seek 4, IO::SEEK_CUR
      @data = Descriptor.new(@file).parse
    end

    def brightness
      @data['Brgh']
    end

    def contrast
      @data['Cntr']
    end

    def mean_value
      @data['means']
    end

    def lab_color
      @data['Lab ']
    end

    def use_legacy
      @data['useLegacy']
    end

    def auto
      @data['Auto']
    end
  end
end
