class PSD
  class Layer
    attr_reader :top, :left, :bottom, :right, :channels
    attr_reader :rows, :cols

    def initialize(file)
      @file = file
      @image = nil
      @mask = {}
      @blendingRanges = {}
      @adjustments = {}
      @channels_info = []
      @blendMode = {}

      @layerType = 'normal'
      @blendingMode = 'normal'
      @opacity = 255
      @fillOpacity = 255
    end

    def parse(index=nil)
      @idx = index

      parse_info
      parse_blend_modes

      extra_len = @file.read_int
      layer_end = @file.tell + extra_len

      @file.seek layer_end

      return self
    end

    def width
      cols
    end

    def height
      rows
    end

    def folder?

    end

    def hidden?

    end

    private

    def parse_info
      @top = @file.read_int
      @left = @file.read_int
      @bottom = @file.read_int
      @right = @file.read_int
      @channels = @file.read_short
      # @top, @left, @bottom, @right, @channels = @file.read(18).unpack('l4s>')
      @rows = @bottom - @top
      @cols = @right - @left

      @channels.times do
        channel_id = @file.read_short
        channel_length = @file.read_int

        @channels_info << {id: channel_id, length: channel_length}
      end
    end

    def parse_blend_modes
      @blendMode = BlendMode.read(@file)

      @blendingMode = @blendMode.mode
      @opacity = @blendMode.opacity
      @visible = @blendMode.visible
    end
  end
end