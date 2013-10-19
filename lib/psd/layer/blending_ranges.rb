class PSD
  class Layer
    module BlendingRanges
      attr_reader :blending_ranges
      
      private
      
      def parse_blending_ranges
        length = @file.read_int

        @blending_ranges[:grey] = {
          source: {
            black: @file.read_short,
            white: @file.read_short
          },
          dest: {
            black: @file.read_short,
            white: @file.read_short
          }
        }

        @blending_ranges[:num_channels] = (length - 8) / 8

        @blending_ranges[:channels] = []
        @blending_ranges[:num_channels].times do
          @blending_ranges[:channels] << {
            source: {
              black: @file.read_short,
              white: @file.read_short
            },
            dest: {
              black: @file.read_short,
              white: @file.read_short
            }
          }
        end
      end
    end
  end
end