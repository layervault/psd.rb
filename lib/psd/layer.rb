class PSD
  # Represents a single layer and all of the data associated with
  # that layer.
  class Layer
    include Section

    attr_reader :id, :mask, :blending_ranges, :adjustments, :channels_info
    attr_reader :blend_mode, :layer_type, :blending_mode, :opacity, :fill_opacity
    attr_reader :channels, :image

    attr_accessor :group_layer
    attr_accessor :top, :left, :bottom, :right, :rows, :cols, :ref_x, :ref_y, :node, :file

    alias :info :adjustments
    alias :width :cols
    alias :height :rows

    # All of the extra layer info sections that we know how to parse.
    LAYER_INFO = {
      type: TypeTool,
      legacy_type: LegacyTypeTool,
      layer_name_source: LayerNameSource,
      object_effects: ObjectEffects,
      name: UnicodeName,
      section_divider: LayerSectionDivider,
      reference_point: ReferencePoint,
      layer_id: LayerID,
      fill_opacity: FillOpacity,
      placed_layer: PlacedLayer,
      vector_mask: VectorMask
    }

    # Initializes all of the defaults for the layer.
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

      # Just used for tracking which layer adjustments we're parsing.
      # Not essential.
      @info_keys = []
    end

    # Parse the layer and all of it's sub-sections.
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

      PSD.logger.debug "Layer name = #{name}"

      @file.seek @layer_end # Skip over any filler zeros

      end_section
      return self
    end

    # Export the layer to file. May or may not work.
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

    # We just delegate this to a normal method call.
    def [](val)
      self.send(val)
    end

    def parse_channel_image!(header, parse)
      @image = ChannelImage.new(@file, header, self)
      parse ? @image.parse : @image.skip
    end

    # Does this layer represent the start of a folder section?
    def folder?
      return false unless @adjustments.has_key?(:section_divider)
      @adjustments[:section_divider].is_folder
    end

    # Does this layer represent the end of a folder section?
    def folder_end?
      return false unless @adjustments.has_key?(:section_divider)
      @adjustments[:section_divider].is_hidden
    end

    # Is this layer visible?
    def visible?
      @visible
    end

    # Is this layer hidden?
    def hidden?
      !@visible
    end

    # Attempt to translate this layer and modify the document.
    def translate(x=0, y=0)
      @left += x
      @right += x
      @top += y
      @bottom += y

      @path_components.each{ |p| p.translate(x,y) } if @path_components
    end

    # Attempt to scale the path components within this layer.
    def scale_path_components(xr, yr)
      return unless @path_components

      @path_components.each{ |p| p.scale(xr, yr) }
    end

    # Helper that exports the text data in this layer, if any.
    def text
      return nil unless @adjustments[:type]
      @adjustments[:type].to_hash
    end

    # Gets the name of this layer. If the PSD file is from an even remotely
    # recent version of Photoshop, this data is stored as extra layer info and
    # as a UTF-16 name. Otherwise, it's stored in a legacy block.
    def name
      if @adjustments.has_key?(:name)
        return @adjustments[:name].data
      end

      return @legacy_name
    end

    # We delegate all missing method calls to the extra layer info to make it easier
    # to access that data.
    def method_missing(method, *args, &block)
      return @adjustments[method] if @adjustments.has_key?(method)
      super
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

      len = Util.pad4 @file.read(1).bytes.to_a[0]
      @legacy_name = @file.read_string(len)

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
        key = @file.read_string(4)
        @info_keys << key

        length = Util.pad2 @file.read_int
        pos = @file.tell

        info_parsed = false
        LAYER_INFO.each do |name, info|
          next unless info.key == key

          PSD.logger.debug "Layer Info: key = #{key}, start = #{pos}, length = #{length}"

          begin
            i = info.new(@file, length)
            i.parse

            @adjustments[name] = i
            info_parsed = true
          rescue Exception => e
            PSD.logger.error "Parsing error: key = #{key}, message = #{e.message}"
            PSD.logger.error e.backtrace.join("\n")
          end

          break
        end

        if !info_parsed
          PSD.logger.debug "Skipping: key = #{key}, pos = #{@file.tell}, length = #{length}"
          @file.seek pos + length
        end

        @file.seek pos + length if @file.tell != (pos + length)
      end

      @extra_data_end = @file.tell
    end

    def write_vector_mask(outfile)
      outfile.write @file.read(8)
      # outfile.write_int 3
      # outfile.write_int @vector_tag

      @path_components.each{ |pc| pc.write(outfile); @file.seek(26, IO::SEEK_CUR) }
    end
  end
end