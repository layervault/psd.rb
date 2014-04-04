class PSD
  # Parses and reads all of the Resource records in the document.
  class Resources
    attr_reader :resources
    alias :data :resources
    
    def initialize(file)
      @file = file
      @resources = {}
      @type_index = {}
      @length = nil
    end

    # Parses each Resource and stores them.
    def parse
      finish = length + @file.tell

      while @file.tell < finish
        resource = Resource.new(@file)
        resource.parse

        resource_end = @file.tell + resource.size

        name = Resource::Section.factory(@file, resource)
        @resources[resource.id] = resource
        @type_index[name] = resource.id unless name.nil?

        @file.seek resource_end
      end

      @file.seek finish if @file.tell != finish
    end

    def skip
      @file.seek length, IO::SEEK_CUR
    end

    def [](id)
      if id.is_a?(Symbol)
        by_type(id)
      else
        @resources[id]
      end
    end

    def by_type(id)
      @resources[@type_index[id]]
    end

    def length
      @length ||= @file.read_int
    end
  end
end