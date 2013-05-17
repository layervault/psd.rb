class PSD::Node
  class Layer < PSD::Node
    PROPERTIES = [:name, :left, :right, :top, :bottom, :height, :width]

    def initialize(layer)
      @layer = layer
    end

    PROPERTIES.each do |meth|
      define_method meth do
        @layer.send(meth)
      end

      define_method "#{meth}=" do |val|
        @layer.send("#{meth}=", val)
      end
    end

    def to_hash
      hash = {}
      PROPERTIES.each do |p|
        hash[p] = self.send(p)
      end

      return hash
    end
  end
end