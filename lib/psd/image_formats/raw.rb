class PSD::Image
  module Format
    module RAW
      private

      def parse_raw!(length = @length)
        return parse_channel_raw! if is_layer_image?

        @length.times do |i|
          @channel_data[i] = @file.read(1).bytes.to_a[0]
        end
      end

      def parse_channel_raw!
        data = @file.read(@ch_info.length - 2).bytes.to_a
        data_index = 0

        (@chan_pos...@chan_pos + @ch_info.length - 2).each do |i|
          @channel_data[i] = data[data_index]
          data_index += 1
        end

        @chan_pos += @ch_info.length - 2
      end
    end
  end
end