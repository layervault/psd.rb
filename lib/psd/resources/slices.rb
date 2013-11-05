class PSD
  class Resource
    class Section
        class Slices < Section
          attr_reader :data, :version

          def self.id; 1050; end
          def self.name; :slices; end

          def parse
            @version = @file.read_int
            @descriptor_version = @file.read_int
            @resource.data = self

            if @version == 7 || @version == 8
              @data = Descriptor.new(@file).parse
            end

          end

          def to_a
            unless @data.nil?
              @data['slices']
            end
          end
        end
    end
  end
end