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
            next unless channels == 4
            pixel[:a] = @channel_data[i + (@channel_length * index)]
          when 0 then pixel[:r] = @channel_data[i + (@channel_length * index)]
          when 1 then pixel[:g] = @channel_data[i + (@channel_length * index)]
          when 2 then pixel[:b] = @channel_data[i + (@channel_length * index)]
          end

          index += 1
        end

        @pixel_data.push pixel[:r], pixel[:g], pixel[:b], pixel[:a]
      end
    end

    def combine_rgb16_channel
      (0...@num_pixels).step(2) do |i|
        index = 0
        pixel = {r: 0, g: 0, b: 0, a: 255}

        @channels_info.each do |chan|
          b1 = @channel_data[i + (@channel_length * index) + 1]
          b2 = @channel_data[i + (@channel_length * index)]
          val = Util.toUInt16(b1, b2)

          case chan[:id]
          when -1
            next unless channels == 4
            pixel[:a] = val
          when 0 then pixel[:r] = val
          when 1 then pixel[:g] = val
          when 2 then pixel[:b] = val
          end

          index += 1
        end

        @pixel_data.push pixel[:r], pixel[:g], pixel[:b], pixel[:a]
      end
    end
  end
end