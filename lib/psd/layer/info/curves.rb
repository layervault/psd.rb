require 'psd/layer_info'

class PSD
  class Curves < LayerInfo
    def self.should_parse?(key)
      key == 'curv'
    end

    attr_reader :curves

    def parse
      # Padding, spec is wrong. Maybe Photoshop bug?
      @file.seek 1, IO::SEEK_CUR

      # Version
      @file.seek 2, IO::SEEK_CUR

      tag = @file.read_int
      curve_count = 0

      # Legacy data, it looks like there are 32 positions
      # where you can adjust the curve, and there is a chunk
      # of 32 bytes that determine whether that chunk is set.
      32.times do |i|
        curve_count += 1 if tag & (1 << i) > 0
      end

      @curves = []
      curve_count.times do |i|
        # Before each curve is a channel index
        count = 0
        curve = {}
        32.times do |j|
          if tag & (1 << j) > 0
            if count == i
              curve[:channel_index] = j
              break
            end

            count += 1
          end
        end

        point_count = @file.read_short
        curve[:points] = point_count.times.map do
          {
            output_value: @file.read_short,
            input_value: @file.read_short
          }
        end

        @curves << curve
      end

      if @file.tell < @section_end - 4
        tag = @file.read_string(4)
        raise "Extra curves key error: #{tag}" if tag != 'Crv '

        @file.seek 2, IO::SEEK_CUR

        curve_count = @file.read_int
        curve_count.times do
          curve = { channel_index: @file.read_short }

          point_count = @file.read_short
          curve[:points] = point_count.times.map do
            {
              output_value: @file.read_short,
              input_value: @file.read_short
            }
          end

          @curves << curve
        end
      end
    end
  end
end
