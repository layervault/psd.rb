class PSD
  class LayerStyles
    module ColorOverlay
      private

      def apply_color_overlay
        # TODO - implement CMYK color overlay
        return if @node.header.cmyk?

        overlay_data = data['SoFi']
        color_data = overlay_data['Clr ']
        blending_mode = BlendMode::BLEND_MODES[BLEND_TRANSLATION[overlay_data['Md  ']].to_sym]

        width = canvas.width
        height = canvas.height

        PSD.logger.debug "Layer style: layer = #{node.name}, type = color overlay, blend mode = #{blending_mode}"

        for y in 0...height do
          for x in 0...width do
            pixel = canvas[x, y]
            alpha = ChunkyPNG::Color.a(pixel)
            next if alpha == 0

            overlay_color = ChunkyPNG::Color.rgba(
              color_data['Rd  '].round, 
              color_data['Grn '].round,
              color_data['Bl  '].round,
              alpha
            )

            color = Compose.send(blending_mode, overlay_color, pixel)
            canvas[x, y] = color
          end
        end
      end
    end
  end
end