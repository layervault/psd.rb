class PSD::Node
  class Layer < PSD::Node
    def initialize(layer)
      @layer = layer
    end

    [:name, :left, :right, :top, :bottom, :rows, :cols, :height, :width].each do |meth|
      define_method meth do
        @layer.send(meth)
      end
    end

    def to_hash
      {
        name: name,
        height: height,
        width: width
      }
    end
  end
end