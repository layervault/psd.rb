class PSD
  class Renderer
    class ClippingMask
      attr_reader :canvas, :mask

      def initialize(canvas)
        @canvas = canvas
        @node = @canvas.node
        
        mask_node = @canvas.node.next_sibling
        @mask = Canvas.new(mask_node)

        width, height = @node.document_dimensions
        @document_width = width.to_i
        @document_height = height.to_i
      end

      def apply!
        return unless @canvas.node.clipped?

        PSD.logger.debug "Applying clipping mask #{mask.node.name} to #{@node.name}"

        full_png = compose_to_full

        @document_height.times do |y|
          @document_width.times do |x|
            if y < mask.node.top || y > mask.node.bottom || x < mask.node.left || x > mask.node.right
              alpha = 0
            else
              mask_x = x - mask.node.left
              mask_y = y - mask.node.top

              pixel = mask.canvas.pixels[mask_y * mask.width + mask_x]
              alpha = pixel.nil? ? 0 : ChunkyPNG::Color.a(pixel)
            end
            
            color = full_png[x, y]
            full_png[x, y] = (color & 0xffffff00) | (ChunkyPNG::Color.a(color) * alpha / 255)
          end
        end

        full_png.crop!(@canvas.left, @canvas.top, @canvas.width, @canvas.height)
        @canvas.canvas = full_png
      end

      private

      def compose_to_full
        full_png = ChunkyPNG::Canvas.new(@document_width, @document_height, ChunkyPNG::Color::TRANSPARENT)
        full_png.compose!(@canvas.canvas, @node.left, @node.top)
        return full_png
      end
    end
  end
end