class PSD
  # Parses and reads all of the Resource records in the document.
  class Resources
    include Section

    attr_reader :resources
    alias :data :resources
    
    def initialize(file)
      @file = file
      @resources = {}
      @length = nil
    end

    # Parses each Resource and stores them.
    def parse
      start_section

      n = length
      start = @file.tell

      while n > 0
        pos = @file.tell

        resource = Resource.new(@file)
        resource.parse

        resource_end = @file.tell + resource.size

        Resource::Section.factory(@file, resource)
        @resources[resource.id] = resource

        @file.seek resource_end
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

    def [](id)
      @resources[id]
    end

    private

    def length
      return @length unless @length.nil?
      @length = @file.read_int
    end
  end
end