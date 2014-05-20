require 'psd/nodes/ancestry'
require 'psd/nodes/search'
require 'psd/nodes/layer_comps'
require 'psd/nodes/build_preview'

# Internal structure to help us build trees of a Photoshop documents.
# A lot of method names borrowed from the Ruby ancestry gem.
class PSD
  module Node
    class Base
      include Enumerable
      include Ancestry
      include Search
      include LayerComps
      include BuildPreview

      # Default properties that all nodes contain
      PROPERTIES = [:name, :left, :right, :top, :bottom, :height, :width]

      attr_reader :name, :parent
      attr_accessor :children, :layer, :force_visible, :top_offset, :left_offset

      delegate :psd, to: :parent
      delegate :name, to: :layer
      delegate :each, to: :children
      delegate :document_dimensions, to: :parent

      def initialize(layer, parent = nil)
        @layer = layer
        @layer.node = self

        @parent = parent
        @children = []
        
        @force_visible = nil
        @top = @layer.top.to_i
        @bottom = @layer.bottom.to_i
        @left = @layer.left.to_i
        @right = @layer.right.to_i

        @top_offset = 0
        @left_offset = 0
      end

      def top
        @top + @top_offset
      end

      def bottom
        @bottom + @top_offset
      end

      def left
        @left + @left_offset
      end

      def right
        @right + @left_offset
      end

      def width
        right - left
      end

      def height
        bottom - top
      end

      def hidden?
        !visible?
      end

      def visible?
        return false if @layer.clipped? && !clipping_mask.visible?
        @force_visible.nil? ? @layer.visible? : @force_visible
      end

      def clipping_mask
        return nil unless @layer.clipped?

        @clipping_mask ||= (
          mask_node = next_sibling
          while mask_node.clipped?
            mask_node = mask_node.next_sibling
          end

          mask_node
        )
      end
      alias_method :clipped_by, :clipping_mask

      def layer?
        is_a?(PSD::Node::Layer)
      end

      def group?(include_root = true)
        is_a?(PSD::Node::Group) || (include_root && is_a?(PSD::Node::Root))
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

      protected

      def update_dimensions!
        return if layer?

        children.each { |child| child.update_dimensions! }

        return if root?

        non_empty_children = children.reject(&:empty?)
        @left = non_empty_children.map(&:left).min || 0
        @top = non_empty_children.map(&:top).min || 0
        @bottom = non_empty_children.map(&:bottom).max || 0
        @right = non_empty_children.map(&:right).max || 0
      end
    end
  end
end