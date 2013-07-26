class PSD
  # Parses and reads all of the Resource records in the document.
  class Resources
    include Section

    attr_reader :resources
    alias :data :resources
    
    def initialize(file)
      @file = file
      @resources = []
    end

    # Parses each Resource and stores them.
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
  end
end