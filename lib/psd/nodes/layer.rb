class PSD::Node
  class Layer < PSD::Node
    def initialize(layer)
      @layer = layer
    end

    def name
      @layer.name
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

    def to_hash
      {
        name: name,
        # layer: @layer
      }
    end
  end
end