class PSD
  class Node
    module BuildPreview
      include PSD::Image::Export::PNG

      alias :orig_to_png :to_png
      def to_png
        return build_png if group?
        layer.image.to_png_with_mask
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
            compose!(
              c,
              png,
              c.image.to_png_with_mask,
              PSD::Util.clamp(c.left.to_i, 0, png.width),
              PSD::Util.clamp(c.top.to_i, 0, png.height)
            )
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
      def compose!(layer, base, other, offset_x, offset_y)
        blending_mode = layer.blending_mode.gsub(/ /, '_')
        PSD.logger.warn("Blend mode #{blending_mode} is not implemented") unless Compose.respond_to?(blending_mode)
        PSD.logger.debug("Blending #{layer.name} with #{blending_mode} blend mode")

        LayerStyles.new(layer, other).apply!
        other = ClippingMask.new(layer, other).apply

        blend_pixels!(blending_mode, layer, base, other, offset_x, offset_y)
      end

      def blend_pixels!(blending_mode, layer, base, other, offset_x, offset_y)
        other.height.times do |y|
          other.width.times do |x|
            base_x = x + offset_x
            base_y = y + offset_y

            next if base_x < 0 || base_y < 0 || base_x >= base.width || base_y >= base.height

            color = Compose.send(
              blending_mode,
              other[x, y],
              base[base_x, base_y],
              opacity: layer.opacity,
              fill_opacity: layer.fill_opacity
            )

            base[base_x, base_y] = color
          end
        end
      end
    end
  end
end
