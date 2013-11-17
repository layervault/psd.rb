require RUBY_ENGINE =~ /jruby/ ? 'chunky_png' : 'oily_png'

class PSD::Image
  module Export
    # PNG image export. This is the default export format.
    module PNG
      # Load the image pixels into a PNG file and return a reference to the
      # data.
      def to_png
        PSD.logger.debug "Beginning PNG export"
        png = ChunkyPNG::Canvas.new(width.to_i, height.to_i, ChunkyPNG::Color::TRANSPARENT)

        i = 0
        height.times do |y|
          width.times do |x|
            png[x,y] = @pixel_data[i]
            i += 1
          end
        end

        png
      end
      alias :export :to_png

      def to_png_with_mask
        return to_png unless has_mask?

        PSD.logger.debug "Beginning PNG export with mask"
        
        # We generate the preview at the document size instead to make applying the mask
        # significantly easier.
        width = @layer.header.width.to_i
        height = @layer.header.height.to_i
        png = ChunkyPNG::Canvas.new(width, height, ChunkyPNG::Color::TRANSPARENT)

        i = 0
        @layer.height.times do |y|
          @layer.width.times do |x|
            png[x + @layer.left, y + @layer.top] = @pixel_data[i]
            i += 1
          end
        end
        
        # Now we apply the mask
        i = 0
        @layer.mask.height.times do |y|
          @layer.mask.width.times do |x|
            offset_x = @layer.mask.left + x
            offset_y = @layer.mask.top + y

            color = ChunkyPNG::Color.to_truecolor_alpha_bytes(png.get_pixel(offset_x, offset_y))
            color[3] = color[3] * @mask_data[i] / 255

            png.set_pixel(offset_x, offset_y, ChunkyPNG::Color.rgba(*color))
            i += 1
          end
        end

        png.crop!(@layer.left, @layer.top, @layer.width.to_i, @layer.height.to_i)
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
    end
  end
end