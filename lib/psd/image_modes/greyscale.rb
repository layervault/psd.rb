class PSD
  module ImageMode
    module Greyscale
      private

      def combine_greyscale_channel
        if channels == 2
          (0...@num_pixels).step(pixel_step) do |i|
            alpha = @channel_data[i]
            grey = @channel_data[@channel_length + i]

            @pixel_data.push grey, grey, grey, alpha
          end
        else
          (0...@num_pixels).step(pixel_step) do |i|
            @pixel_data.push *([@channel_data[i]] * 3), 255
          end
        end
      end
    end
  end
end