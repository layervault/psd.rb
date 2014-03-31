class PSD
  class Renderer
    class MaskCanvas < Canvas
      def initialize(node, width = nil, height = nil, opts = {})
        super
        apply_mask
      end
    end
  end
end