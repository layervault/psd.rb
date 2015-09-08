class PSD
  # Covers parsing the global mask and controls parsing of all the
  # layers/folders in the document.
  class LayerMask
    attr_reader :layers, :global_mask

    # Store a reference to the file and the header and initialize the defaults.
    def initialize(file, header, options)
      @file = file
      @header = header
      @options = options

      @layers = []
      @merged_alpha = false
      @global_mask = nil
    end

    # Allows us to skip this section because it starts with the length of the section
    # stored as an integer.
    def skip
      @file.seek parse_mask_size, IO::SEEK_CUR
      return self
    end

    # Parse this section, including all of the layers and folders.
    def parse
      mask_size = parse_mask_size

      start_position = @file.tell
      finish = start_position + mask_size

      PSD.logger.debug "Layer mask section: #{start_position} - #{finish}"

      return self if mask_size <= 0

      parse_layers
      parse_global_mask

      consumed_bytes = @file.tell - start_position
      parse_layer_tagged_blocks(mask_size - consumed_bytes)

      # Layers are parsed in reverse order
      layers.reverse!

      # Ensure we're at the end of this section
      @file.seek finish

      self
    end

    private

    def parse_mask_size
      @header.big? ? @file.read_longlong : @file.read_int
    end

    def parse_layer_info_size
      Util.pad2(@header.big? ? @file.read_longlong : @file.read_int)
    end

    def channel_information_length
      @header.big? ? 10 : 6
    end

    def parse_layers
      layer_info_size = parse_layer_info_size

      if layer_info_size > 0
        layer_count = @file.read_short

        if layer_count < 0
          layer_count = layer_count.abs
          @merged_alpha = true
        end

        if layer_count * (18 + channel_information_length * @header.channels) > layer_info_size
          PSD.logger.error "Unlikely number of layers parsed: #{layer_count}"
        end

        @layer_section_start = @file.tell
        layer_count.times do
          @layers << PSD::Layer.new(@file, @header).parse
        end

        layers.each do |layer|
          layer.parse_channel_image(@header)
        end
      end
    end

    def parse_layer_tagged_blocks(remaining_length)
      end_pos = @file.tell + remaining_length

      while @file.tell < end_pos
        res = parse_additional_layer_info_block
        break unless res
      end
    end

    def parse_additional_layer_info_block
      sig = @file.read_string(4)

      unless %w(8BIM 8B64).include?(sig)
        @file.seek(-4, IO::SEEK_CUR)
        return false
      end

      key = @file.read_string(4)

      if %w(Lr16 Lr32 Mt16).include?(key)
        parse_layers
        return true
      end

      false
    end

    def parse_global_mask
      length = @file.read_int

      PSD.logger.debug "Global Mask: length = #{length}"
      return if length <= 0

      mask_end = @file.tell + length

      @global_mask = {}
      @global_mask[:overlay_color_space] = @file.read_short
      @global_mask[:color_components] = 4.times.map { |i| @file.read_short >> 8 }
      @global_mask[:opacity] = @file.read_short / 16.0

      # 0 = color selected, 1 = color protected, 128 = use value per layer
      @global_mask[:kind] = @file.read(1).bytes.to_a[0]

      PSD.logger.debug @global_mask

      # Filler zeros
      @file.seek mask_end
    end
  end
end
