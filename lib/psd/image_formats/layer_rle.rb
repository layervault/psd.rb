class PSD
  module ImageFormat
    # Some method overrides for layer images.
    module LayerRLE
      private

      def parse_byte_counts!
        byte_counts = []
        height.times do
          byte_counts << @file.read_short
        end

        return byte_counts
      end

      def parse_channel_data!
        line_index = 0

        channels.times do |i|
          PSD.logger.debug "Parsing layer RLE channel ##{i}: position = #{@chan_pos}, line = #{line_index}"
          @chan_pos = decode_rle_channel(@chan_pos, line_index)
          line_index += height
        end
      end
    end
  end
end