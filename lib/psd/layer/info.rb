class PSD
  class Layer
    module Info
      # All of the extra layer info sections that we know how to parse.
      LAYER_INFO = {
        type: TypeTool,
        legacy_type: LegacyTypeTool,
        metadata: MetadataSetting,
        layer_name_source: LayerNameSource,
        object_effects: ObjectEffects,
        name: UnicodeName,
        section_divider: LayerSectionDivider,
        nested_section_divider: NestedLayerDivider,
        reference_point: ReferencePoint,
        layer_id: LayerID,
        fill_opacity: FillOpacity,
        placed_layer: PlacedLayer,
        vector_mask: VectorMask
      }

      attr_reader :adjustments
      alias :info :adjustments

      private

      # This section is a bit tricky to parse because it represents all of the
      # extra data that describes this layer.
      def parse_layer_info
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
              i = info.new(self, length)
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

          if @file.tell != (pos + length)
            PSD.logger.warn "Layer info key #{key} ended at #{@file.tell}, expected #{pos + length}"
            @file.seek pos + length
          end
        end

        @extra_data_end = @file.tell
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
    end
  end
end