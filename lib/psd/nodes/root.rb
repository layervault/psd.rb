# Represents the root node of a Photoshop document
class PSD::Node
  class Root < PSD::Node
    include PSD::HasChildren
    include PSD::Node::ParseLayers

    attr_reader :children

    def initialize(psd)
      @psd = psd
      build_hierarchy
    end

    def to_hash
      {
        children: children.map(&:to_hash),
        document: {
          width: document_width,
          height: document_height
        }
      }
    end

    def document_dimensions
      [@psd.header.width, @psd.header.height]
    end

    def document_width
      @psd.header.width.to_i
    end

    def document_height
      @psd.header.height.to_i
    end

    def name
      nil
    end

    private

    def build_hierarchy
      @children = []
      result = { layers: [] }
      parseStack = []

      # First we build the hierarchy
      @psd.layers.each do |layer|
        if layer.folder?
          parseStack << result
          result = { name: layer.name, layer: layer, layers: [] }
        elsif layer.folder_end?
          temp = result
          result = parseStack.pop
          result[:layers] << temp
        else
          result[:layers] << layer
        end
      end

      parse_layers(result[:layers])
    end
  end
end