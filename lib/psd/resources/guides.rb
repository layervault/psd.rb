require 'lib/psd/resources/base'

class PSD
  class Resource
    module Section
      class Guides < Base
        resource_id 1032
        name :guides

        def parse
          # Descriptor version
          @file.seek 4, IO::SEEK_CUR

          # Future implementation of document-specific grids
          @file.seek 8, IO::SEEK_CUR

          num_guides = @file.read_int

          @data = []

          num_guides.times do
            location = @file.read_int / 32
            direction = @file.read_byte == 0 ? "vertical" : "horizontal"

            @data.push({ :location => location, :direction => direction })
          end

          @resource.data = self
        end

        def to_a
          @data
        end
      end
    end
  end
end