class PSD
  class LayerMask
    attr_reader :layers

    def initialize(file, header)
      @file = file
      @header = header

      @layers = []
      @mergedAlpha = false
      @globalMask = {}
      @extras = []
    end

    def skip
      @file.seek @file.read_int, IO::SEEK_CUR
    end

    def parse
      

      return self
    end
  end
end