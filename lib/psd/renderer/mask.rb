class PSD
  class Renderer
    class Mask
      attr_accessor :mask_data

      def initialize(canvas, mask_layer = nil)
        @canvas = canvas
        @layer = canvas.node
        @mask_layer = mask_layer || @layer

        @mask_data = @mask_layer.image.mask_data
        @mask = @mask_layer.mask

        @mask_width = @mask.width.to_i
        @mask_height = @mask.height.to_i
        @mask_left = @mask.left.to_i + @mask_layer.left_offset
        @mask_top = @mask.top.to_i + @mask_layer.top_offset

        @doc_width = @layer.header.width.to_i
        @doc_height = @layer.header.height.to_i
      end

      def apply!
        PSD.logger.debug "Applying mask to #{@layer.name}"

        @canvas.height.times do |y|
          @canvas.width.times do |x|
            doc_x = @canvas.left + x
            doc_y = @canvas.top + y

            mask_x = doc_x - @mask_left
            mask_y = doc_y - @mask_top

            color = ChunkyPNG::Color.to_truecolor_alpha_bytes(@canvas.get_pixel(x, y))

            if doc_x < 0 || doc_x >= @doc_width || doc_y < 0 || doc_y >= @doc_height
              color[3] = 0
            elsif mask_x < 0 || mask_x >= @mask_width || mask_y < 0 || mask_y >= @mask_height
              color[3] = 0
            else
              color[3] = color[3] * @mask_data[@mask_width * mask_y + mask_x] / 255
            end

            @canvas.set_pixel x, y, ChunkyPNG::Color.rgba(*color)
          end
        end
      end
    end
  end
end