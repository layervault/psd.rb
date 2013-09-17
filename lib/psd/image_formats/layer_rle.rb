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
        @line_index = 0

        PSD.logger.debug "Parsing layer RLE channel ##{@ch_info[:id]}: position = #{@chan_pos}"
        decode_rle_channel
      end
    end
  end
end