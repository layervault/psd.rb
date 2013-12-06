class PSD::Image
  module Export
    module LayerPNG
      # Load the image pixels into a PNG file and return a reference to the
      # data.
      def to_png(layer_styles=true)
        return @png if @png
        
        PSD.logger.debug "Beginning layer PNG export"
        @png = ChunkyPNG::Canvas.new(width.to_i, height.to_i, ChunkyPNG::Color::TRANSPARENT)

        i = 0
        height.times do |y|
          width.times do |x|
            @png[x,y] = @pixel_data[i]
            i += 1
          end
        end

        PSD::LayerStyles.new(@layer, transparent_base, @png).apply! if layer_styles

        @png
      end
      alias :export :to_png

      def to_png_with_mask(layer_styles=true)
        return to_png(layer_styles) unless has_mask?
        return @png_with_mask if @png_with_mask

        PSD.logger.debug "Beginning PNG export with mask"
        
        # We generate the preview at the document size instead to make applying the mask
        # significantly easier.
        width = @layer.header.width.to_i
        height = @layer.header.height.to_i
        png = ChunkyPNG::Canvas.new(width, height, ChunkyPNG::Color::TRANSPARENT)

        i = 0
        @layer.height.times do |y|
          @layer.width.times do |x|
            offset_x = x + @layer.left
            offset_y = y + @layer.top

            i +=1 and next if offset_x < 0 || offset_y < 0 || offset_x >= png.width || offset_y >= png.height

            png[offset_x, offset_y] = @pixel_data[i]
            i += 1
          end
        end
        
        # Now we apply the mask
        i = 0
        @layer.mask.height.times do |y|
          @layer.mask.width.times do |x|
            offset_x = @layer.mask.left + x
            offset_y = @layer.mask.top + y

            i += 1 and next if offset_x < 0 || offset_y < 0 || offset_x >= png.width || offset_y >= png.height

            color = ChunkyPNG::Color.to_truecolor_alpha_bytes(png[offset_x, offset_y])
            color[3] = color[3] * @mask_data[i] / 255

            png[offset_x, offset_y] = ChunkyPNG::Color.rgba(*color)
            i += 1
          end
        end

        crop_left = PSD::Util.clamp(@layer.left, 0, png.width)
        crop_top = PSD::Util.clamp(@layer.top, 0, png.height)
        crop_width = PSD::Util.clamp(@layer.width.to_i, 0, png.width - crop_left)
        crop_height = PSD::Util.clamp(@layer.height.to_i, 0, png.height - crop_top)

        png.crop!(crop_left, crop_top, crop_width, crop_height)
        PSD::LayerStyles.new(@layer, transparent_base, png).apply! if layer_styles

        @png_with_mask = png and return @png_with_mask
      end

      def mask_to_png
        return unless has_mask?

        png = ChunkyPNG::Canvas.new(@layer.mask.width.to_i, @layer.mask.height.to_i, ChunkyPNG::Color::TRANSPARENT)

        i = 0
        @layer.mask.height.times do |y|
          @layer.mask.width.times do |x|
            png[x, y] = ChunkyPNG::Color.grayscale(@mask_data[i])
            i += 1
          end
        end

        png
      end

      # Saves the PNG data to disk.
      def save_as_png(file)
        to_png.save(file, :fast_rgba)
      end

      def transparent_base
        ChunkyPNG::Canvas.new(width.to_i, height.to_i, ChunkyPNG::Color::TRANSPARENT)
      end
    end
  end
end