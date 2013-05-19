# Internal structure to help us build trees of a Photoshop documents.
# A lot of method names borrowed from the Ruby ancestry gem.
class PSD
  class Node
    include Ancestry
    include Search

    attr_accessor :parent, :children

    def initialize(layers=[])
      @children = []
      layers.each do |layer|
        layer.parent = self
        @children << layer
      end
    end
  end
end