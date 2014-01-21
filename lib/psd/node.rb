require_relative 'nodes/ancestry'
require_relative 'nodes/search'

# Internal structure to help us build trees of a Photoshop documents.
# A lot of method names borrowed from the Ruby ancestry gem.
class PSD
  class Node
    include Ancestry
    include Search
    include BuildPreview

    # Default properties that all nodes contain
    PROPERTIES = [:name, :left, :right, :top, :bottom, :height, :width]

    attr_accessor :parent, :children, :layer, :force_visible

    def initialize(layers=[])
      @children = []
      layers.each do |layer|
        layer.parent = self
        @children << layer
      end

      @force_visible = nil
    end

    def hidden?
      !visible?
    end

    def visible?
      force_visible.nil? ? @layer.visible? : force_visible
    end

    def psd
      parent.psd
    end

    def layer?
      is_a?(PSD::Node::Layer)
    end

    def group?
      is_a?(PSD::Node::Group) || is_a?(PSD::Node::Root)
    end

    def debug_name
      root? ? ":root:" : name
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