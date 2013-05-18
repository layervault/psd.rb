require 'pp'
class PSD
  class Layer < Node
    include Section

    attr_reader :id, :name, :mask, :blending_ranges, :adjustments, :channels_info
    attr_reader :blend_mode, :layer_type, :blending_mode, :opacity, :fill_opacity
    attr_reader :channels, :image

    attr_accessor :group_layer
    attr_accessor :top, :left, :bottom, :right, :rows, :cols, :ref_x, :ref_y, :node, :file

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
      start_section

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

      end_section
      return self
    end

    def export(outfile)
      export_info(outfile)

      @blend_mode.write(outfile)
      @file.seek(@blend_mode.num_bytes, IO::SEEK_CUR)

      export_mask_data(outfile)
      export_blending_ranges(outfile)
      export_legacy_layer_name(outfile)
      export_extra_data(outfile)

      outfile.write @file.read(end_of_section - @file.tell)
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

    def translate(x=0, y=0)
      @left += x
      @right += x
      @top += y
      @bottom += y

      @path_components.each{ |p| p.translate(x,y) }
    end

    def document_dimensions
      @node.document_dimensions
    end

    private

    def parse_info
      start_section(:info)

      @top = @file.read_int
      @left = @file.read_int
      @bottom = @file.read_int
      @right = @file.read_int
      @channels = @file.read_short

      @rows = @bottom - @top
      @cols = @right - @left

      @channels.times do
        channel_id = @file.read_short
        channel_length = @file.read_int

        @channels_info << {id: channel_id, length: channel_length}
      end

      end_section(:info)
    end

    def export_info(outfile)
      [@top, @left, @bottom, @right].each { |val| outfile.write_int(val) }
      outfile.write_short(@channels)

      @channels_info.each do |channel_info|
        outfile.write_short channel_info[:id]
        outfile.write_int channel_info[:length]
      end

      @file.seek end_of_section(:info)
    end

    def export_mask_data(outfile)
      #@mask.write outfile
      outfile.write @file.read(@mask_end - @mask_begin + 4)
    end

    def export_blending_ranges(outfile)
      length = 4 * 2 # greys
      length += @blending_ranges[:num_channels] * 8
      outfile.write_int length

      outfile.write_short @blending_ranges[:grey][:source][:black]
      outfile.write_short @blending_ranges[:grey][:source][:white]
      outfile.write_short @blending_ranges[:grey][:dest][:black]
      outfile.write_short @blending_ranges[:grey][:dest][:white]

      @blending_ranges[:num_channels].times do |i|
        outfile.write_short @blending_ranges[:channels][i][:source][:black]
        outfile.write_short @blending_ranges[:channels][i][:source][:white]
        outfile.write_short @blending_ranges[:channels][i][:dest][:black]
        outfile.write_short @blending_ranges[:channels][i][:dest][:white]
      end

      @file.seek length + 4, IO::SEEK_CUR
    end

    def export_legacy_layer_name(outfile)
      # if @legacy_name
      #   string = PascalString.new(initial_value: @legacy_name)
      #   string.write outfile
      #   @file.seek string.num_bytes, IO::SEEK_CUR
      # end
      outfile.write @file.read(@legacy_name_end - @legacy_name_start)
    end

    def export_extra_data(outfile)
      outfile.write @file.read(@extra_data_end - @extra_data_begin)
      if @path_components && !@path_components.empty?
        outfile.seek @vector_mask_begin
        @file.seek @vector_mask_begin

        write_vector_mask(outfile)
        @file.seek outfile.tell
      end
    end

    def parse_blend_modes
      @blend_mode = BlendMode.read(@file)

      @blending_mode = @blend_mode.mode
      @opacity = @blend_mode.opacity
      @visible = @blend_mode.visible
    end

    def parse_mask_data
      @mask_begin = @file.tell
      @mask = Mask.read(@file)
      @mask_end = @file.tell
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
      @legacy_name_start = @file.tell
      len = Util.pad4 @file.read(1).unpack('C')[0]
      @legacy_name = @file.read(len).encode('UTF-8', 'MacRoman').delete("\000")
      @legacy_name_end = @file.tell
    end

    # This section is a bit tricky to parse because it represents all of the
    # extra data that describes this layer.
    def parse_extra_data
      @extra_data_begin = @file.tell

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
        when 'vmsk' then parse_vector_mask(length)
        when 'fxrp' then parse_reference_point
        when 'shmd' then parse_metadata
        else
          @file.seek length, IO::SEEK_CUR
        end

        @file.seek pos + length if @file.tell != (pos + length)
      end

      @extra_data_end = @file.tell
    end

    def read_layer_section_divider
      code = @file.read_int
      @layer_type = SECTION_DIVIDER_TYPES[code]

      case code
      when 1, 2 then @is_folder = true
      when 3 then @is_hidden = true
      end
    end

    def parse_vector_mask(length)
      @vector_mask_begin = @file.tell
      raise "Vector mask malformed" unless 3 == @file.read_int
      @vector_tag = @file.read_int
      invert = @vector_tag & 0x01
      not_link = (@vector_tag & (0x01 << 1)) > 0
      disable = (@vector_tag & (0x01 << 2)) > 0

      num_records = (length - 8) / 26

      @path_components = []
      num_records.times do
        @path_components << PathRecord.read(self)
      end

      @vector_mask_end = @file.tell
    end

    def write_vector_mask(outfile)
      outfile.write @file.read(8)
      # outfile.write_int 3
      # outfile.write_int @vector_tag

      @path_components.each{ |pc| pc.write(outfile); @file.seek(26, IO::SEEK_CUR) }
    end

    def parse_reference_point
      @ref_x, @ref_y = @file.read_double, @file.read_double
    end

    def parse_metadata
      metadata_items = @file.read_uint

      metadata_items.times do
        @file.seek 4, IO::SEEK_CUR
        key = @file.read(4).unpack('A4')[0]
        copy_on_sheet = @file.read(1)
        padding = @file.read(3)
        len = @file.read_uint
        data = @file.read len
      end
    end
  end
end