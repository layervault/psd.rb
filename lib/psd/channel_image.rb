require File.dirname(File.absolute_path(__FILE__)) + "/image"

class PSD
  class ChannelImage < Image
    def initialize(file, header, layer)
      @layer = layer
      @width = @layer.width
      @height = @layer.height

      super file, header

      @channels_info = @layer.channels_info
    end

    def is_layer_image?
      true
    end

    def width
      @width
    end

    def height
      @height
    end

    def channels
      @layer.channels
    end

    def parse
      @chan_pos = 0

      channels.times do |i|
        @ch_info = @channels_info[i]

        if @ch_info[:length] <= 0
          parse_compression! and next
        end

        if @ch_info[:id] == -2
          @width = @layer.mask.width
          @height = @layer.mask.height
        else
          @width = @layer.width
          @height = @layer.height
        end

        start = @file.tell
        parse_image_data!
        finish = @file.tell

        if finish != start + @ch_info[:length]
          puts "ERROR: read incorrect number of bytes"
          @file.seek start + @ch_info[:length]
        end
      end

      process_image_data
      return self
    end

    def parse_image_data!
      @compression = parse_compression!

      case @compression
      when 0 then parse_raw!
      when 1 then parse_rle!
      when 2, 3 then parse_zip!
      else @file.seek(@end_pos)
      end
    end
  end
end