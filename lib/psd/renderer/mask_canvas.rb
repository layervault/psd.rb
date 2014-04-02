require_relative './canvas'

class PSD
  class Renderer
    class MaskCanvas < Canvas
      def initialize(node, width = nil, height = nil, opts = {})
        super
        apply_masks
      end
    end
  end
end