class PSD
  class Node
    module BuildPreview
      include PSD::Image::Export::PNG

      alias :orig_to_png :to_png
      def to_png
        return build_png if group?
        layer.image.to_png
      end

      def build_png(png=nil)
        png ||= create_canvas

        children.reverse.each do |c|
          next unless c.visible?
          
          if c.group?
            if c.blending_mode == 'passthru'
              c.build_png(png)
            else
              compose! c, png, c.build_png, 0, 0
            end
          else
            compose! c, png, c.image.to_png, c.left.to_i, c.top.to_i
          end
        end

        png
      end

      private

      def create_canvas
        width, height = document_dimensions
        ChunkyPNG::Canvas.new(width.to_i, height.to_i, ChunkyPNG::Color::TRANSPARENT)
      end

      # Modified from ChunkyPNG::Canvas#compose! in order to support various blend modes.
      def compose!(layer, base, other, offset_x = 0, offset_y = 0)
        blending_mode = layer.blending_mode.gsub(/ /, '_')
        PSD.logger.warn("Blend mode #{blending_mode} is not implemented") unless Compose.respond_to?(blending_mode)
        PSD.logger.debug("Blending #{layer.name} with #{blending_mode} blend mode")

        for y in 0...other.height do
          for x in 0...other.width do
            color = Compose.send(blending_mode, other.get_pixel(x, y), base.get_pixel(x + offset_x, y + offset_y), layer)
            base.set_pixel(x + offset_x, y + offset_y, color)
          end
        end
      end
    end
  end
end