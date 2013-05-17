# Represents the root node of a Photoshop document
class PSD
  class Root < Node
    include PSD::HasChildren

    def initialize(layers)
      @children = []
      layers.each do |layer|
        layer.parent = self
        @children << layer
      end
    end
  end
end