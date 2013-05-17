class PSD::Node
  class Layer < PSD::Node
    include PSD::Node::LockToOrigin

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

    def translate(x,y)
      @layer.left += x
      @layer.right += x
      @layer.top += y
      @layer.bottom += y
    end

    def hide!
      # TODO actually mess with the blend modes instead of
      # just putting things way off canvas
      return if @hidden_by_kelly
      translate(100000, 10000)
      @hidden_by_kelly = true
    end

    def show!
      if @hidden_by_kelly
        translate(-100000, -10000)
        @hidden_by_kelly = false
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