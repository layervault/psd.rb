class PSD
  class Resource
    class Section
        class Slices < Section
          attr_reader :data

          def self.id; 1050; end
          def self.name; :slices; end

          def parse
            @version = @file.read_int
            @descriptor_version = @file.read_int

            @data = Descriptor.new(@file).parse
            @resource.data = self
          end

          def to_a
            @data['slices']
          end
        end
    end
  end
end