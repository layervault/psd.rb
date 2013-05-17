class PSD
  class Resources < Section
    def initialize(file)
      @file = file
      @resources = []
    end

    def parse
      start_section

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

      end_section
      return @resources
    end

    def data
      @resources
    end
  end
end