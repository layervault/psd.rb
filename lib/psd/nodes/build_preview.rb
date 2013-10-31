class PSD
  class Node
    module BuildPreview
      include PSD::Image::Export::PNG

      alias :orig_to_png :to_png
      def to_png
        width, height = document_dimensions
        png = ChunkyPNG::Canvas.new(width.to_i, height.to_i, ChunkyPNG::Color::TRANSPARENT)
        
        build_pixel_data(png)
        png
      end

      def build_pixel_data(png)
        children.reverse.each do |c|
          next unless c.visible?
          
          if c.group?
            c.build_pixel_data(png)
          else
            PSD.logger.warn("Blend mode #{c.blending_mode} is not implemented") unless Compose.respond_to?(c.blending_mode)
            compose! c.blending_mode, png, c.image.to_png, c.left.to_i, c.top.to_i
          end
        end
      end

      private

      # Modified from ChunkyPNG::Canvas#compose! in order to support various blend modes.
      def compose!(blend_mode, base, other, offset_x = 0, offset_y = 0)
        for y in 0...other.height do
          for x in 0...other.width do
            color = Compose.send(blend_mode, other.get_pixel(x, y), base.get_pixel(x + offset_x, y + offset_y))
            base.set_pixel(x + offset_x, y + offset_y, color)
          end
        end
      end
    end
  end
end