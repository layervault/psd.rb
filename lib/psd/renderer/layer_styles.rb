require 'lib/psd/renderer/layer_styles/color_overlay'

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
    }.freeze

    SUPPORTED_STYLES = [
      ColorOverlay
    ].freeze

    attr_reader :canvas, :node, :data

    def initialize(canvas)
      @canvas = canvas
      @node = @canvas.node
      @data = @node.object_effects

      if @data.nil?
        @applied = true
      else
        @data = @data.data
        @applied = false
      end
    end

    def apply!
      return if @applied || data.nil?

      SUPPORTED_STYLES.each do |style|
        next unless style.should_apply?(@canvas, data)
        style.new(self).apply!
      end
    end
  end
end