class PSD::Node
  class Layer < PSD::Node
    def initialize(layer)
      @layer = layer
    end

    def left
      @layer.left
    end

    def right
      @layer.right
    end

    def top
      @layer.top
    end

    def bottom
      @layer.bottom
    end
  end
end