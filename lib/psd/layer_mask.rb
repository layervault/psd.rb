class PSD
  class LayerMask
    attr_reader :layers

    def initialize(file, header)
      @file = file
      @header = header

      @layers = []
      @mergedAlpha = false
      @globalMask = {}
      @extras = []
    end

    def skip
      @file.seek @file.read_int, IO::SEEK_CUR
      return self
    end

    def parse
      mask_size = @file.read_int
      finish = @file.tell + mask_size

      return self if mask_size <= 0

      layer_info_size = Util.pad2(@file.read_int)
      pos = @file.tell

      if layer_info_size > 0
        layer_count = @file.read_short

        if layer_count < 0
          layer_count = layer_count.abs
          @mergedAlpha = true
        end

        if layer_count * (18 + 6 * @header.channels) > layer_info_size
          raise "Unlikely number of layers parsed: #{layer_count}"
        end

        layer_count.times do
          @layers << PSD::Layer.new(@file).parse
        end

        layers.each do |layer|
          @file.seek 8, IO::SEEK_CUR and next if layer.folder? || layer.hidden?

          layer.parse_channel_image!(@header)
        end
      end

      # Layers are parsed in reverse order
      layers.reverse!
      group_layers

      # Temporarily seek to the end of this section
      @file.seek finish

      return self
    end

    private

    def group_layers
      group_layer = nil
      layers.each do |layer|
        if layer.folder?
          group_layer = layer
        elsif layer.hidden?
          group_layer = nil
        else
          layer.group_layer = layer
        end
      end
    end
  end
end