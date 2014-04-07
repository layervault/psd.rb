class PSD
  class LayerStyles
    class ColorOverlay
      # TODO: CMYK support
      def self.should_apply?(canvas, data)
        data.has_key?('SoFi') && 
        data['SoFi']['enab'] &&
        canvas.node.header.rgb? &&
        !PSD::Renderer::VectorShape.can_render?(canvas)
      end

      def self.can_apply?(canvas, data)
        data.has_key?('SoFi') && 
        data['SoFi']['enab'] &&
        canvas.node.header.rgb?
      end

      def self.for_canvas(canvas)
        data = canvas.node.object_effects
        return nil if data.nil?
        return nil unless can_apply?(canvas, data.data)

        styles = LayerStyles.new(canvas)
        self.new(styles)
      end

      def initialize(styles)
        @canvas = styles.canvas
        @node = styles.node
        @data = styles.data
      end

      def apply!
        PSD.logger.debug "Layer style: layer = #{@node.name}, type = color overlay, blend mode = #{blending_mode}"

        @canvas.height.times do |y|
          @canvas.width.times do |x|
            pixel = @canvas[x, y]
            alpha = ChunkyPNG::Color.a(pixel)
            next if alpha == 0

            @canvas[x, y] = Compose.send(blending_mode, overlay_color, pixel, alpha)
          end
        end
      end

      def overlay_color
        @overlay_color ||= ChunkyPNG::Color.rgba(r, g, b, a)
      end

      def r
        @r ||= color_data['Rd  '].round
      end

      def g
        @g ||= color_data['Grn '].round
      end

      def b
        @b ||= color_data['Bl  '].round
      end

      def a
        @a ||= (overlay_data['Opct'][:value] * 2.55).ceil
      end

      private

      def blending_mode
        @blending_mode ||= BlendMode::BLEND_MODES[BLEND_TRANSLATION[overlay_data['Md  '][:value]].to_sym]
      end

      def overlay_data
        @data['SoFi']
      end

      def color_data
        overlay_data['Clr ']
      end
    end
  end
end