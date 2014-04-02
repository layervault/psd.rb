class PSD
  class Renderer
    class Canvas
      attr_reader :canvas, :node, :opts, :width, :height, :left, :right, :top, :bottom, :opacity, :fill_opacity

      def initialize(node, width = nil, height = nil, opts = {})
        @node = node
        @opts = opts
        @pixel_data = @node.group? ? [] : @node.image.pixel_data
        
        @width = (width || @node.width).to_i
        @height = (height || @node.height).to_i
        @left = @node.left
        @right = @node.right
        @top = @node.top
        @bottom = @node.bottom

        @opacity = @node.opacity.to_f
        @fill_opacity = @node.fill_opacity.to_f

        initialize_canvas
      end

      def paint_to(base)
        PSD.logger.debug "Painting #{node.name} to #{base.node.debug_name}"

        apply_masks
        apply_clipping_mask
        apply_layer_styles
        apply_layer_opacity

        compose_pixels(base)
      end

      def canvas=(canvas)
        @canvas = canvas
        @width = @canvas.width
        @height = @canvas.height
      end

      def [](x, y); @canvas[x, y]; end
      def []=(x, y, value); @canvas[x, y] = value; end

      def method_missing(method, *args, &block)
        @canvas.send(method, *args, &block)
      end

      private

      def initialize_canvas
        PSD.logger.debug "Initializing canvas for #{node.debug_name}; color = #{ChunkyPNG::Color.to_truecolor_alpha_bytes(fill_color)}"

        @canvas = ChunkyPNG::Canvas.new(@width, @height, fill_color)
        return if @node.group? || has_fill?

        # Sorry, ChunkyPNG.
        @canvas.send(:replace_canvas!, width, height, @pixel_data)
      ensure
        # This can now be referenced by @canvas.pixels
        @pixel_data = nil
      end

      def has_fill?
        !@opts[:base] && @node.layer? && @node.solid_color
      end

      def fill_color
        if has_fill?
          @node.solid_color.color
        else
          ChunkyPNG::Color::TRANSPARENT
        end
      end

      def apply_masks
        ([@node] + @node.ancestors).each do |n|
          next unless n.raster_mask?
          break if n.group? && !n.passthru_blending?

          if n.layer?
            PSD.logger.debug "Applying raster mask to #{@node.name}"
            Mask.new(self).apply!
          else
            PSD.logger.debug "Applying raster mask to #{@node.name} from #{n.name}"
            Mask.new(self, n.image.mask_data, n.mask).apply!
          end
        end
      end

      def apply_clipping_mask
        return unless @node.clipped?
        ClippingMask.new(self).apply!
      end

      def apply_layer_styles
        PSD.logger.debug "Applying layer styles to #{node.name}"
        LayerStyles.new(self).apply!
      end

      def apply_layer_opacity
        return if @node.root?
        PSD.logger.debug "Adjusting opacity for #{node.name}"
        
        @node.ancestors.each do |parent|
          break unless parent.passthru_blending?
          @opacity = (@opacity * parent.opacity.to_f) / 255.0
        end

        PSD.logger.debug "Inherited opacity for #{@node.debug_name} is #{@opacity}"
        @opacity = @opacity.to_i
      end

      def compose_pixels(base)
        Blender.new(self, base).compose!
      end
    end
  end
end