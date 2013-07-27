class PSD::Image::Mode
  # Combines the channel data from the image into RGB pixel values
  module RGB
    private

    def combine_rgb8_channel
      @num_pixels.times do |i|
        pixel = {r: 0, g: 0, b: 0, a: 255}

        PSD::Image::CHANNEL_INFO.each_with_index do |chan, index|
          case chan[:id]
          when -1
            next if channels != 4
            pixel[:a] = @channel_data[i + (@channel_length * index)]
          when 0 then pixel[:r] = @channel_data[i + (@channel_length * index)]
          when 1 then pixel[:g] = @channel_data[i + (@channel_length * index)]
          when 2 then pixel[:b] = @channel_data[i + (@channel_length * index)]
          end
        end

        @pixel_data.push *pixel.values
      end
    end

    def combine_rgb16_channel

    end
  end
end