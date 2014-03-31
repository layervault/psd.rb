class PSD
  class Renderer
    class Mask
      attr_accessor :mask_data

      def initialize(canvas)
        @canvas = canvas
        @layer = canvas.node

        @mask_data = @layer.image.mask_data

        @mask_width = @layer.mask.width.to_i
        @mask_height = @layer.mask.height.to_i
        @mask_left = @layer.mask.left.to_i
        @mask_top = @layer.mask.top.to_i

        @doc_width = @layer.header.width.to_i
        @doc_height = @layer.header.height.to_i
      end

      def apply!        
        # Now we apply the mask
        i = 0
        @mask_height.times do |y|
          @mask_width.times do |x|
            doc_x = @mask_left + x
            doc_y = @mask_top + y

            layer_x = doc_x - @layer.left
            layer_y = doc_y - @layer.top

            next unless @canvas.canvas.include_xy?(layer_x, layer_y)
            color = ChunkyPNG::Color.to_truecolor_alpha_bytes(@canvas[layer_x, layer_y])

            # We're off the document canvas. Crop.
            if doc_x < 0 || doc_x > @doc_width || doc_y < 0 || doc_y > @doc_height
              color[3] = 0
            else
              color[3] = color[3] * @mask_data[i] / 255
            end 

            @canvas[layer_x, layer_y] = ChunkyPNG::Color.rgba(*color)
            i += 1
          end
        end
      end
    end
  end
end