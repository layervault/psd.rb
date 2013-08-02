class PSD::Image
  module Format
    # Parses an RLE compressed image
    module RLE
      private

      def parse_rle!
        @byte_counts = parse_byte_counts!
        parse_channel_data!
      end

      def parse_byte_counts!
        byte_counts = []
        channels.times do |i|
          height.times do |j|
            byte_counts << @file.read_short
          end
        end

        return byte_counts
      end

      def parse_channel_data!
        chan_pos = 0
        line_index = 0

        channels.times do |i|
          PSD.logger.debug "Parsing RLE channel ##{i}: position = #{chan_pos}, line = #{line_index}"
          chan_pos = decode_rle_channel(chan_pos, line_index)
          line_index += height
        end
      end

      def decode_rle_channel(chan_pos, line_index)
        height.times do |j|
          byte_count = @byte_counts[line_index]
          line_index += 1
          finish = @file.tell + byte_count

          while @file.tell < finish
            len = @file.read(1).bytes.to_a[0]

            if len < 128
              len += 1
              (chan_pos...chan_pos+len).each do |k|
                @channel_data[k] = @file.read(1).bytes.to_a[0]
              end

              chan_pos += len
            elsif len > 128
              len ^= 0xff
              len += 2

              val = @file.read(1).bytes.to_a[0]
              (chan_pos...chan_pos+len).each do |k|
                @channel_data[k] = val
              end

              chan_pos += len
            end
          end
        end

        return chan_pos
      end
    end
  end
end