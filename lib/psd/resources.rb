class PSD
  class Resources
    def initialize(file)
      @file = file
      @resources = []
    end

    def parse
      n = @file.read_int
      length = n
      start = @file.tell

      while n > 0
        pos = @file.tell
        @resources << PSD::Resource.read(@file)
        n -= @file.tell - pos
      end

      unless n == 0
        @file.seek start + length
      end

      return @resources
    end
  end
end