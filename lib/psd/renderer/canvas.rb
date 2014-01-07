class PSD
  class Renderer
    class Canvas
      attr_accessor :canvas
      attr_reader :node, :width, :height, :left, :top

      def initialize(node, width, height, color = nil)
        @node = node
        @pixel_data = @node.root? ? [] : @node.image.pixel_data
        
        @width = width.to_i
        @height = height.to_i
        @left = @node.left.to_i
        @top = @node.top.to_i

        @canvas = ChunkyPNG::Canvas.new(@width, @height, (color || ChunkyPNG::Color::TRANSPARENT))

        initialize_canvas
      end

      def paint_to(base)
        PSD.logger.debug "Painting #{node.name} to #{base.node.name || ":root:"}"

        apply_mask
        apply_layer_styles
        apply_layer_opacity
        compose_pixels(base)
      end

      def method_missing(method, *args, &block)
        @canvas.send(method, *args, &block)
      end

      private

      def initialize_canvas
        return if node.root? || node.group?

        PSD.logger.debug "Initializing canvas for #{node.name || ":root:"}"

        i = 0
        height.times do |y|
          width.times do |x|
            @canvas[x, y] = @pixel_data[i]
            i += 1
          end
        end
      end

      def apply_mask
        return unless @node.image.has_mask?

        PSD.logger.debug "Applying layer mask to #{node.name}"
        Mask.new(self).apply!
      end

      def apply_layer_styles
        PSD.logger.debug "Applying layer styles to #{node.name}"
        # LayerStyles.new(self)
      end

      def apply_layer_opacity
        PSD.logger.debug "Adjusting opacity for #{node.name}"
      end

      def compose_pixels(base)
        PSD.logger.debug "Composing #{node.name} onto #{base.node.name || ":root:"} with #{node.blending_mode} blending"

        offset_x = PSD::Util.clamp(@left - base.left, 0, base.width)
        offset_y = PSD::Util.clamp(@top - base.top, 0, base.height) 

        height.times do |y|
          width.times do |x|
            base_x = x + offset_x
            base_y = y + offset_y

            next if base_x < 0 || base_y < 0 || base_x >= base.width || base_y >= base.height

            color = Compose.send(
              @node.blending_mode,
              @canvas[x, y],
              base[base_x, base_y],
              opacity: @node.opacity,
              fill_opacity: @node.fill_opacity
            )

            base[base_x, base_y] = color
          end
        end
      end
    end
  end
end