class PSD::Image::Mode
  module CMYK
    private

    def combine_cmyk_channel
      (0...@num_pixels).step(pixel_step) do |i|
        if channels == 5
          a = @channel_data[i]
          c = @channel_data[i + @channel_length]
          m = @channel_data[i + @channel_length * 2]
          y = @channel_data[i + @channel_length * 3]
          k = @channel_data[i + @channel_length * 4]
        else
          a = 255
          c = @channel_data[i]
          m = @channel_data[i + @channel_length]
          y = @channel_data[i + @channel_length * 2]
          k = @channel_data[i + @channel_length * 3]
        end

        rgb = PSD::Color.cmyk_to_rgb(255 - c, 255 - m, 255 - y, 255 - k)

        @pixel_data.push *rgb.values, a
      end
    end
  end
end