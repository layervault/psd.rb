# Represents the root node of a Photoshop document
class PSD::Node
  class Root < PSD::Node
    include PSD::HasChildren

    attr_reader :children

    def initialize(psd)
      @psd = psd
      parse_layers
    end

    private

    def parse_layers
      @children = []
      result = {layers: []}
      parseStack = []

      # First we build the hierarchy
      @psd.layers.each do |layer|
        if layer.folder?
          parseStack << result
          result = {name: layer.name, layers: []}
        elsif layer.hidden?
          temp = result
          result = parseStack.pop
          result[:layers] << temp
        else
          result[:layers] << layer
        end
      end

      # Now we translate it into nodes
      result[:layers].each do |layer|
        if layer.is_a?(Hash)
          group = PSD::Node::Group.new(layer[:layers])
          group.parent = self
          @children << group
        elsif layer.is_a?(PSD::Layer)
          layer_node = PSD::Node::Layer.new(layer)
          layer_node.parent = self
          @children << layer_node
        end
      end
    end
  end
end