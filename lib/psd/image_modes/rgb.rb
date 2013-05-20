class PSD::Image::Mode
  module RGB
    private

    def combine_rgb8_channel
      @num_pixels.times do |i|
        index = 0
        pixel = {r: 0, g: 0, b: 0, a: 255}

        @channels_info.each do |chan|
          case chan[:id]
          when -1
            next if channels != 4
            pixel[:a] = @channel_data[i + (@channel_length * index)]
          when 0 then pixel[:r] = @channel_data[i + (@channel_length * index)]
          when 1 then pixel[:g] = @channel_data[i + (@channel_length * index)]
          when 2 then pixel[:b] = @channel_data[i + (@channel_length * index)]
          end

          index += 1
        end

        @pixel_data << pixel[:r]
        @pixel_data << pixel[:g]
        @pixel_data << pixel[:b]
        @pixel_data << pixel[:a]
      end
    end

    def combine_rgb16_channel

    end
  end
end