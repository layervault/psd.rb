class PSD
  module Helpers
    def width
      header.cols
    end

    def height
      header.rows
    end

    def layers
      layer_mask.layers
    end

    def actual_layers
      layers.delete_if { |l| l.folder? || l.hidden? }
    end

    def folders
      layers.select { |l| l.folder? }
    end

    # constructs a tree of the current document
    def tree
      @root ||= PSD::Node::Root.new(self)
    end

    def layers_with_structure
      root = PSD::Node::Root.new(self)

      # result = {layers: []}
      # parseStack = []
      # layers.each do |layer|
      #   if layer.folder?
      #     parseStack << result
      #     result = {name: layer.name, layers: []}
      #   elsif layer.hidden?
      #     temp = result
      #     result = parseStack.pop
      #     result[:layers] << temp
      #   else
      #     result[:layers] << layer
      #   end
      # end

      # return result
    end
  end
end