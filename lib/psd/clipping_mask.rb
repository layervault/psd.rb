class PSD
  class ClippingMask
    def initialize(layer, png=nil)
      @layer = layer
      @png = png
    end

    def apply
      return @png unless @layer.clipped?

      PSD.logger.debug "Applying clipping mask #{mask.name} to #{@layer.name}"

      width, height = @layer.document_dimensions
      full_png = compose_to_full

      height.times do |y|
        width.times do |x|
          if y < mask.top || y > mask.bottom || x < mask.left || x > mask.right
            alpha = 0
          else
            mask_x = x - mask.left
            mask_y = y - mask.top

            pixel = mask.image.pixel_data[mask_y * mask.width + mask_x]
            alpha = pixel.nil? ? 0 : ChunkyPNG::Color.a(pixel)
          end
          
          color = ChunkyPNG::Color.to_truecolor_alpha_bytes(full_png[x, y])
          color[3] = color[3] * alpha / 255
          full_png[x, y] = ChunkyPNG::Color.rgba(*color)
        end
      end

      full_png.crop!(@layer.left, @layer.top, @layer.width, @layer.height)
    end

    private

    def mask
      @mask ||= @layer.next_sibling
    end

    def compose_to_full
      width, height = @layer.document_dimensions
      full_png = ChunkyPNG::Canvas.new(width.to_i, height.to_i, ChunkyPNG::Color::TRANSPARENT)
      full_png.compose!(@png, @layer.left, @layer.top)
    end
  end
end