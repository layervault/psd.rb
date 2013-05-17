class PSD
  class Layer
    attr_reader :top, :left, :bottom, :right, :channels
    attr_reader :rows, :cols

    def initialize(file)
      @file = file
      @image = nil
      @mask = {}
      @blending_ranges = {}
      @adjustments = {}
      @channels_info = []
      @blend_mode = {}

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
      @layer_end = @file.tell + extra_len

      parse_mask_data
      parse_blending_ranges
      parse_legacy_layer_name
      parse_extra_data

      @file.seek @layer_end

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
      @blend_mode = BlendMode.read(@file)

      @blendingMode = @blend_mode.mode
      @opacity = @blend_mode.opacity
      @visible = @blend_mode.visible
    end

    def parse_mask_data
      @mask = Mask.read(@file)
    end

    def parse_blending_ranges
      length = @file.read_int

      @blending_ranges[:grey] = {
        source: {
          black: @file.read_short,
          white: @file.read_short
        },
        dest: {
          black: @file.read_short,
          white: @file.read_short
        }
      }

      @blending_ranges[:num_channels] = (length - 8) / 8

      @blending_ranges[:channels] = []
      @blending_ranges[:num_channels].times do
        @blending_ranges[:channels] << {
          source: {
            black: @file.read_short,
            white: @file.read_short
          },
          dest: {
            black: @file.read_short,
            white: @file.read_short
          }
        }
      end
    end

    # The old school layer names are encoded in MacRoman format,
    # not UTF-8. Luckily Ruby kicks ass at character conversion.
    def parse_legacy_layer_name
      len = Util.pad4 @file.read(1).unpack('C')[0]
      @legacy_name = @file.read(len).encode('UTF-8', 'MacRoman')
    end

    # This section is a bit tricky to parse because it represents all of the
    # extra data that describes this layer.
    def parse_extra_data
      while @file.tell < @layer_end
        # Signature, don't need
        @file.seek 4, IO::SEEK_CUR

        # Key, very important
        key = @file.read(4).unpack('A4')[0]

        length = Util.pad2 @file.read_int
        pos = @file.tell

        case key
        when 'luni' # Unicode layer name
          len = @file.read_int * 2
          @name = @file.read(len).unpack("A#{len}")[0].encode('UTF-8')

          # The name seems to be padded with null bytes. This is the easiest solution.
          @file.seek pos + length
        else
          @file.seek length, IO::SEEK_CUR
        end

        @file.seek pos + length if @file.tell != (pos + length)
      end
    end
  end
end