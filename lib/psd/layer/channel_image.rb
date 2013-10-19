class PSD
  class Layer
    module ChannelImage
      def parse_channel_image!(header, parse)
        @image = PSD::ChannelImage.new(@file, header, self)
        parse ? @image.parse : @image.skip
      end
    end
  end
end