class PSD::Image
  module Export
    module LayerPNG
      # Load the image pixels into a PNG file and return a reference to the
      # data.
      def to_png(options = {})
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

        PSD::LayerStyles.new(@layer, transparent_base, @png).apply! if options[:layer_styles]

        @png
      end
      alias :export :to_png

      def to_png_with_mask(options = {})
        return to_png(options) unless has_mask?
        return @png_with_mask if @png_with_mask

        service = PSD::MaskService.new(@layer, options)
        @png_with_mask = service.apply

        return @png_with_mask        
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