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

      def export_blending_ranges(outfile)
        length = 4 * 2 # greys
        length += @blending_ranges[:num_channels] * 8
        outfile.write_int length

        outfile.write_short @blending_ranges[:grey][:source][:black]
        outfile.write_short @blending_ranges[:grey][:source][:white]
        outfile.write_short @blending_ranges[:grey][:dest][:black]
        outfile.write_short @blending_ranges[:grey][:dest][:white]

        @blending_ranges[:num_channels].times do |i|
          outfile.write_short @blending_ranges[:channels][i][:source][:black]
          outfile.write_short @blending_ranges[:channels][i][:source][:white]
          outfile.write_short @blending_ranges[:channels][i][:dest][:black]
          outfile.write_short @blending_ranges[:channels][i][:dest][:white]
        end

        @file.seek length + 4, IO::SEEK_CUR
      end
    end
  end
end