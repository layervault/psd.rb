require_relative 'image'

class PSD
  # Represents an image for a single layer, which differs slightly in format from
  # the full size preview image.
  class ChannelImage < Image
    include ImageFormat::LayerRLE
    include ImageFormat::LayerRAW

    attr_reader :width, :height

    def initialize(file, header, layer)
      @layer = layer

      @width = @layer.width
      @height = @layer.height

      super(file, header)

      @channels_info = @layer.channels_info
    end

    def skip
      PSD.logger.debug "Skipping channel image data. Layer = #{@layer.name}"
      @channels_info.each do |ch|
        @file.seek ch.length, IO::SEEK_CUR
      end
    end

    def channels
      @layer.channels
    end

    def parse
      PSD.logger.debug "Layer = #{@layer.name}, Size = #{width}x#{height}"

      @chan_pos = 0

      @channels_info.each do |ch_info|
        @ch_info = ch_info
        if ch_info[:length] <= 0
          parse_compression! and next
        end

        # If the ID of this current channel is -2, then we assume the dimensions
        # of the layer mask.
        if ch_info[:id] == -2
          @width = @layer.mask.width
          @height = @layer.mask.height
        else
          @width = @layer.width
          @height = @layer.height
        end

        start = @file.tell

        PSD.logger.debug "Channel ##{ch_info[:id]}, length = #{ch_info[:length]}"
        parse_image_data!

        finish = @file.tell

        if finish != start + ch_info[:length]
          PSD.logger.error "Read incorrect number of bytes for channel ##{ch_info[:id]}. Expected = #{ch_info[:length]}, Actual = #{finish - start}"
          @file.seek start + @ch_info[:length]
        end
      end

      if @channel_data.length != @length
        PSD.logger.error "#{channel_data.length} read; expected #{@length}"
      end

      process_image_data
    end

    def parse_image_data!
      @compression = parse_compression!

      case @compression
      when 0 then parse_raw!
      when 1 then parse_rle!
      when 2, 3 then parse_zip!
      else
        PSD.logger.error "Unknown image compression. Attempting to skip."
        @file.seek(@end_pos)
      end
    end
  end
end