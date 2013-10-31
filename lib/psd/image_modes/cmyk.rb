class PSD
  module ImageMode
    module CMYK
      private

      def combine_cmyk_channel
        (0...@num_pixels).step(pixel_step) do |i|
          c = @channel_data[i]
          m = @channel_data[i + @channel_length]
          y = @channel_data[i + @channel_length * 2]
          k = @channel_data[i + @channel_length * 3]
          a = (channels == 5 ? @channel_data[i + @channel_length * 4] : 255)

          rgb = PSD::Color.cmyk_to_rgb(255 - c, 255 - m, 255 - y, 255 - k)

          @pixel_data.push ChunkyPNG::Color.rgba(*rgb.values, a)
        end
      end
    end
  end
end