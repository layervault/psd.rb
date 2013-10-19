class PSD
  class Layer
    module Exporting
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

      def write_vector_mask(outfile)
        outfile.write @file.read(8)
        # outfile.write_int 3
        # outfile.write_int @vector_tag

        @path_components.each{ |pc| pc.write(outfile); @file.seek(26, IO::SEEK_CUR) }
      end
    end
  end
end