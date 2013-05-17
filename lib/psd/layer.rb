class PSD
  class Layer < Node
    attr_reader :top, :left, :bottom, :right, :channels
    attr_reader :rows, :cols
    attr_reader :id, :name, :mask, :blending_ranges, :adjustments, :channels_info
    attr_reader :blend_mode, :layer_type, :blending_mode, :opacity, :fill_opacity
    attr_reader :image

    attr_accessor :group_layer

    SECTION_DIVIDER_TYPES = [
      "other",
      "open folder",
      "closed folder",
      "bounding section divider"
    ]

    def initialize(file)
      @file = file
      @image = nil
      @mask = {}
      @blending_ranges = {}
      @adjustments = {}
      @channels_info = []
      @blend_mode = {}
      @group_layer = nil

      @layer_type = 'normal'
      @blending_mode = 'normal'
      @opacity = 255
      @fill_opacity = 255
      @is_folder = false
      @is_hidden = false
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

      @name = @legacy_name unless @name

      @file.seek @layer_end # Skip over any filler zeros

      return self
    end

    def [](val)
      self.send(val)
    end

    def parse_channel_image!(header)
      # @image = ChannelImage.new(@file, header, self)
    end

    def width
      cols
    end

    def height
      rows
    end

    def folder?
      @is_folder
    end

    def hidden?
      @is_hidden
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

      @blending_mode = @blend_mode.mode
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
      @legacy_name = @file.read(len).encode('UTF-8', 'MacRoman').delete("\000")
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
          @name = @file.read(len).unpack("A#{len}")[0].encode('UTF-8').delete("\000")

          # The name seems to be padded with null bytes. This is the easiest solution.
          @file.seek pos + length
        when 'lsct' then read_layer_section_divider
        when 'lyid' then @id = @file.read_int
        else
          @file.seek length, IO::SEEK_CUR
        end

        @file.seek pos + length if @file.tell != (pos + length)
      end
    end

    def read_layer_section_divider
      code = @file.read_int
      @layer_type = SECTION_DIVIDER_TYPES[code]

      case code
      when 1, 2 then @is_folder = true
      when 3 then @is_hidden = true
      end
    end
  end
end