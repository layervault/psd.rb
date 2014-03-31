class PSD
  class Renderer
    class VectorMask < Mask
      def initialize(canvas)
        super

        mask = VectorShape.new(canvas).render!
        
        @mask_data = mask.pixels { |pixel| ChunkyPNG::Color.a(pixel) }
        
        @mask_width = mask.width
        @mask_height = mask.height
        # @mask_left = 0
        # @mask_top = 0
      end
    end
  end
end