require 'psd/nodes/ancestry'
require 'psd/nodes/build_preview'
require 'psd/nodes/search'
require 'psd/nodes/layer_comps'
require 'psd/nodes/locking'

# Internal structure to help us build trees of a Photoshop documents.
# A lot of method names borrowed from the Ruby ancestry gem.
class PSD
  module Node
    class Base
      extend Forwardable

      include Enumerable
      include Ancestry
      include Search
      include LayerComps
      include BuildPreview
      include Locking

      # Default properties that all nodes contain
      PROPERTIES = [:name, :left, :right, :top, :bottom, :height, :width]

      attr_reader :id, :name, :parent
      attr_accessor :children, :layer, :force_visible, :top_offset, :left_offset

      def_delegators :parent, :psd, :document_dimensions
      def_delegator :layer, :name
      def_delegator :children, :each

      def initialize(layer, parent = nil)
        @layer = layer
        @layer.node = self

        @parent = parent
        @children = []
        
        @id = begin layer.layer_id.id rescue nil end
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

      # Color label is a little tricky. If you set the color of a group, all
      # of it's descendants inhert the color unless manually overridden. So,
      # if this node has no defined color, we have to walk up the ancestry tree
      # to make sure the color isn't set somewhere else.
      def color_label
        color = layer.sheet_color.color
        return color if color != :no_color || node.parent.root?

        parent.color_label
      end

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
          blending_mode: @layer.blending_mode,
          layer_comps: {}
        }

        PROPERTIES.each do |p|
          hash[p] = self.send(p)
        end

        root.psd.layer_comps.each do |comp|
          hash[:layer_comps][comp[:name]] = {
            visible: visible_in_comp?(comp[:id]),
            position: position_in_comp(comp[:id])
          }
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

require 'psd/nodes/group'
require 'psd/nodes/layer'
require 'psd/nodes/root'
