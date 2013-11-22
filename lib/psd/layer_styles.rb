class PSD
  class LayerStyles
    include ColorOverlay
    include DropShadow

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
      apply_drop_shadow if data.has_key?('DrSh')

      png
    end
  end
end