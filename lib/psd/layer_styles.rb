class PSD
  class LayerStyles
    # Blend modes in layer effects use different keys
    # than normal layer blend modes. Thanks Adobe.
    BLEND_TRANSLATION = {
      'Nrml' => 'norm',
      'Dslv' => 'diss',
      'Drkn' => 'dark',
      'Mltp' => 'mul',
      'CBrn' => 'idiv',
      'linearBurn' => 'lbrn',
      'Lghn' => 'lite',
      'Scrn' => 'scrn',
      'CDdg' => 'div',
      'linearDodge' => 'lddg',
      'Ovrl' => 'over',
      'SftL' => 'sLit',
      'HrdL' => 'hLit',
      'vividLight' => 'vLit',
      'linearLight' => 'lLit',
      'pinLight' => 'pLit',
      'hardMix' => 'hMix',
      'Dfrn' => 'diff',
      'Xclu' => 'smud',
      'H   ' => 'hue',
      'Strt' => 'sat',
      'Clr ' => 'colr',
      'Lmns' => 'lum'
    }

    attr_reader :layer, :data, :png

    def initialize(layer, png=nil)
      @layer = layer
      @data = layer.info[:object_effects]
      @png = png || layer.image.to_png

      if @data.nil?
        @applied = true
      else
        @data = @data.data
        @applied = false
      end
    end

    def apply!
      return png if @applied || data.nil?

      apply_color_overlay if data.has_key?('SoFi')
      png
    end

    private

    def apply_color_overlay
      overlay_data = data['SoFi']
      color_data = overlay_data['Clr ']
      blending_mode = BlendMode::BLEND_MODES[BLEND_TRANSLATION[overlay_data['Md  ']].to_sym]

      width = layer.width.to_i
      height = layer.height.to_i

      PSD.logger.debug("Layer style: layer = #{layer.name}, type = color overlay, blend mode = #{blending_mode}")

      for y in 0...height do
        for x in 0...width do
          pixel = png.get_pixel(x, y)
          alpha = ChunkyPNG::Color.a(pixel)
          next if alpha == 0

          overlay_color = ChunkyPNG::Color.rgba(
            color_data['Rd  '].round, 
            color_data['Grn '].round,
            color_data['Bl  '].round,
            alpha
          )

          color = Compose.send(blending_mode, overlay_color, pixel)
          png.set_pixel(x, y, color)
        end
      end
    end
  end
end