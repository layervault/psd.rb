class PSD
  class LayerInfo
    attr_reader :data

    class << self; attr_accessor :key; end
    @key = ""

    def initialize(file, length)
      @file = file
      @length = length
      @section_end = @file.tell + @length
      @data = {}
    end

    # Override this - default seeks to end of section
    def parse
      @file.seek @section_end
    end
  end
end