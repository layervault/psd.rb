require_relative 'nodes/ancestry'
require_relative 'nodes/search'

# Internal structure to help us build trees of a Photoshop documents.
# A lot of method names borrowed from the Ruby ancestry gem.
class PSD
  class Node
    include Ancestry
    include Search

    # Default properties that all nodes contain
    PROPERTIES = [:name, :left, :right, :top, :bottom, :height, :width]

    attr_accessor :parent, :children

    def initialize(layers=[])
      @children = []
      layers.each do |layer|
        layer.parent = self
        @children << layer
      end
    end

    def hidden?
      !@layer.visible?
    end

    def visible?
      @layer.visible?
    end

    def layer?
      is_a?(PSD::Node::Layer)
    end

    def group?
      is_a?(PSD::Node::Group)
    end

    def to_hash
      hash = {
        type: nil,
        visible: visible?,
        opacity: @layer.opacity / 255.0,
        blending_mode: @layer.blending_mode
      }

      PROPERTIES.each do |p|
        hash[p] = self.send(p)
      end

      hash
    end

    def document_dimensions
      @parent.document_dimensions
    end
  end
end