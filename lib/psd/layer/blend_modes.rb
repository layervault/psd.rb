class PSD
  class Layer
    module BlendModes
      attr_reader :blend_mode

      delegate :opacity, :visible, :clipped?, to: :blend_mode
      alias_method :visible?, :visible

      # Is this layer hidden?
      def hidden?
        !visible
      end

      def blending_mode
        if !info[:section_divider].nil? && info[:section_divider].blend_mode
          BlendMode::BLEND_MODES[info[:section_divider].blend_mode.strip.to_sym]
        else
          @blend_mode.mode
        end
      end

      private
      
      def parse_blend_modes
        @blend_mode = BlendMode.new(@file)
        @blend_mode.parse!
      end
    end
  end
end