# Internal structure to help us build trees of a Photoshop documents
class PSD
  class Node
    attr_accessor :parent, :children

    def initialize(layers)
      @children = []
      layers.each do |layer|
        layer.parent = self
        @children << layer
      end
    end
  end
end