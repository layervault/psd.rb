class PSD::Image
  module Format
    module RLE
      private

      def parse_rle!
        @byte_counts = parse_byte_counts!
        parse_channel_data!
      end

      def parse_byte_counts!
        return parse_channel_byte_counts! if is_layer_image?

        byte_counts = []
        channels.times do |i|
          height.times do |j|
            byte_counts << @file.read_short
          end
        end

        return byte_counts
      end

      # For channel images, each channel has it's own byte counts
      # and compression.
      def parse_channel_byte_counts!
        byte_counts = []
        height.times do |i|
          byte_counts << @file.read_short
        end

        return byte_counts
      end

      def parse_channel_data!
        return parse_layer_channel_data! if is_layer_image?
        
        chan_pos = 0
        line_index = 0

        channels.times do |i|
          chan_pos, line_index = decode_rle_channel(chan_pos, line_index)
        end
      end

      def parse_layer_channel_data!
        line_index = 0
        @chan_pos, line_index = decode_rle_channel(@chan_pos, line_index)
      end

      def decode_rle_channel(chan_pos, line_index)
        height.times do |j|
          byte_count = @byte_counts[line_index]
          line_index += 1
          start = @file.tell

          while @file.tell < start + byte_count
            len = @file.read(1).bytes.to_a[0]

            if len < 128
              len += 1
              data = @file.read(len).bytes.to_a

              data_index = 0
              (chan_pos...chan_pos+len).to_a.each do |k|
                @channel_data[k] = data[data_index]
                data_index += 1
              end

              chan_pos += len
            elsif len > 128
              len ^= 0xff
              len += 2

              val = @file.read(1).bytes.to_a[0]
              data = []
              len.times { |i| data << val }

              data_index = 0
              (chan_pos...chan_pos+len).to_a.each do |k|
                @channel_data[k] = data[data_index]
                data_index += 1
              end

              chan_pos += len
            end
          end
        end

        return chan_pos, line_index
      end
    end
  end
end