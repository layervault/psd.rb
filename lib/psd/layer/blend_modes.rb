class PSD
  class Layer
    module BlendModes
      def parse_blend_modes
        @blend_mode = BlendMode.read(@file)

        @blending_mode = @blend_mode.mode
        @opacity = @blend_mode.opacity
        @visible = @blend_mode.visible
      end
    end
  end
end