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
        @left = @node.left.to_i
        @right = @node.right.to_i
        @top = @node.top.to_i
        @bottom = @node.bottom.to_i

        @opacity = @node.opacity.to_f
        @fill_opacity = @node.fill_opacity.to_f

        initialize_canvas
      end

      def paint_to(base)
        PSD.logger.debug "Painting #{node.name} to #{base.node.debug_name}"

        render_vector_shape
        apply_mask
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
        return if @node.group?

        # Sorry, ChunkyPNG.
        @canvas.send(:replace_canvas!, width, height, @pixel_data)

        # This can now be referenced by @canvas.pixels
        @pixel_data = nil
      end

      def fill_color
        if !@node.root? && @node.solid_color
          @node.solid_color.color
        else
          ChunkyPNG::Color::TRANSPARENT
        end
      end

      def render_vector_shape
        return unless VectorShape.can_render?(self)
        VectorShape.new(self).render_to_canvas!
      end

      def apply_mask
        return unless @node.image.has_mask?
        return if VectorShape.can_render?(self) # Skip if there's a vector shape, for now

        PSD.logger.debug "Applying layer mask to #{node.name}"
        Mask.new(self).apply!
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