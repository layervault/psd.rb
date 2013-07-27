class PSD
  # Parses and reads all of the Resource records in the document.
  class Resources
    include Section

    attr_reader :resources
    alias :data :resources
    
    def initialize(file)
      @file = file
      @resources = []
      @length = nil
    end

    # Parses each Resource and stores them.
    def parse
      start_section

      n = length
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

    def skip
      @file.seek length, IO::SEEK_CUR
    end

    private

    def length
      return @length unless @length.nil?
      @length = @file.read_int
    end
  end
end