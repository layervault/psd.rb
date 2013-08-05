require 'xmp'

class PSD
  class Resource
    class Section
      class XMPMetadata < Section
        def self.id; 1060; end
        def self.name; :xmp_metadata; end

        def parse
          @resource.data = XMP.new(@file.read_string(@resource.size))
        end
      end
    end
  end
end