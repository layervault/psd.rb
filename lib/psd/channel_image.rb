class PSD
  # Represents an image for a single layer, which differs slightly in format from
  # the full size preview image.
  class ChannelImage < Image
    attr_reader :width, :height

    def initialize(file, header, layer)
      @layer = layer

      @width = @layer.width
      @height = @layer.height
      @channels_info = @layer.channels_info

      super(file, header)
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
      PSD.logger.warn "Parsing channel images not supported yet."
      skip and return
      
      PSD.logger.debug "Layer = #{@layer.name}, Size = #{width}x#{height}"

      @chan_pos = 0

      channels.times do |i|
        @ch_info = @channels_info[i]
        if @ch_info.length <= 0
          parse_compression! and next
        end

        # If the ID of this current channel is -2, then we assume the dimensions
        # of the layer mask.
        if @ch_info.id == -2
          @width = @layer.mask.width
          @height = @layer.mask.height
        else
          @width = @layer.width
          @height = @layer.height
        end

        start = @file.tell

        PSD.logger.debug "Channel ##{@ch_info.id}, length = #{@ch_info.length}"
        parse_image_data!

        finish = @file.tell


      end
    end
  end
end

require_relative 'image'