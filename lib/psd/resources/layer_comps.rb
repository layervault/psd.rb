class PSD
  class Resource
    class Section
      class LayerComps < Section
        def self.id; 1065; end
        def self.name; :layer_comps; end

        def parse
          # Descriptor version
          @file.seek 4, IO::SEEK_CUR
          @resource.data = Descriptor.new(@file).parse
        end
      end
    end
  end
end