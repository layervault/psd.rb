require_relative '../layer_info'

class PSD
  class LayerSectionDivider < LayerInfo
    @key = 'lsct'

    attr_reader :layer_type, :is_folder, :is_hidden

    SECTION_DIVIDER_TYPES = [
      "other",
      "open folder",
      "closed folder",
      "bounding section divider"
    ]

    def initialize(file, length)
      super

      @is_folder = false
      @is_hidden = false
    end

    def parse
      code = @file.read_int
      @layer_type = SECTION_DIVIDER_TYPES[code]

      case code
      when 1, 2 then @is_folder = true
      when 3 then @is_hidden = true
      end

      return self
    end
  end
end