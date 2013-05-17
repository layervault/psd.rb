# Internal structure to help us build trees of a Photoshop documents
class PSD
  class Node
    attr_accessor :parent, :children

    def initialize
      @parent = nil
      @children = []
    end
  end
end