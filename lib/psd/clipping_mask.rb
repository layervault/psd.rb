class PSD
  class ClippingMask
    def initialize(layer, png=nil)
      @layer = layer
      @png = png
    end

    def apply
      return @png unless @layer.clipped?

      mask = @layer.next_sibling

      PSD.logger.debug "Applying clipping mask #{mask.name} to #{@layer.name}"

      width, height = @layer.document_dimensions
      full_png = ChunkyPNG::Canvas.new(width.to_i, height.to_i, ChunkyPNG::Color::TRANSPARENT)
      full_png.compose!(@png, @layer.left, @layer.top)

      (mask.top...mask.bottom).each do |y|
        (mask.left...mask.right).each do |x|
          mask_x = x - mask.left
          mask_y = y - mask.top

          color = ChunkyPNG::Color.to_truecolor_alpha_bytes(full_png[x, y])
          color[3] = color[3] * ChunkyPNG::Color.a(mask.image.pixel_data[mask_y * mask.width + mask_x]) / 255
          full_png[x, y] = ChunkyPNG::Color.rgba(*color)
        end
      end

      full_png.crop!(@layer.left, @layer.top, @layer.width, @layer.height)
    end
  end
end