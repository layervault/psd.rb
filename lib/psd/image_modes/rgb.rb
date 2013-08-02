class PSD::Image::Mode
  # Combines the channel data from the image into RGB pixel values
  module RGB
    private

    def combine_rgb_channel
      PSD.logger.debug "Beginning RGB processing"

      (0...@num_pixels).step(pixel_step) do |i|
        r = g = b = 0
        a = 255

        PSD::Image::CHANNEL_INFO.each_with_index do |chan, index|
          next if channels == 3 && chan[:id] == -1
          val = @channel_data[i + (@channel_length * index)]

          case chan[:id]
          when -1 then  a = val
          when 0 then   r = val
          when 1 then   g = val
          when 2 then   b = val
          end
        end

        @pixel_data.push r, g, b, a
      end
    end
  end
end