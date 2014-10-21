require 'psd/node'

class PSD
  module Node
    # Represents the root node of a Photoshop document
    class Root < PSD::Node::Base
      attr_accessor :children
      attr_reader :psd

      alias_method :document_width, :width
      alias_method :document_height, :height

      RootLayer = Struct.new("RootLayer", :node, *Base::PROPERTIES)

      def self.layer_for_psd(psd)
        RootLayer.new.tap do |layer|
          layer.top = 0
          layer.left = 0
          layer.right = psd.header.width.to_i
          layer.bottom = psd.header.height.to_i
        end
      end

      # Stores a reference to the parsed PSD and builds the
      # tree hierarchy.
      def initialize(psd)
        super self.class.layer_for_psd(psd)

        @psd = psd
        build_hierarchy
      end

      # Returns the width and height of the entire PSD document.
      def document_dimensions
        [document_width, document_height]
      end

      # The depth of the root node is always 0.
      def depth
        0
      end

      def opacity; 255; end
      def fill_opacity; 255; end

      # Recursively exports the hierarchy to a Hash
      def to_hash
        {
          children: children.map(&:to_hash),
          document: {
            width: document_width,
            height: document_height,
            depth: psd.header.depth,
            resources: {
              layer_comps: @psd.layer_comps,
              guides: @psd.guides,
              slices: @psd.slices
            }
          }
        }
      end

      private

      def build_hierarchy
        current_group = self
        parse_stack = []

        # First we build the hierarchy
        @psd.layers.each do |layer|
          if layer.folder?
            parse_stack.push current_group
            current_group = PSD::Node::Group.new(layer, parse_stack.last)
          elsif layer.folder_end?
            parent = parse_stack.pop
            parent.children.push current_group
            current_group = parent
          else
            current_group.children.push PSD::Node::Layer.new(layer, current_group)
          end
        end

        update_dimensions!
      end
    end
  end
end
