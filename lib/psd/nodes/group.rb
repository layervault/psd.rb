class PSD::Node
  class Group < PSD::Node
    include PSD::HasChildren
    attr_reader :top, :left, :bottom, :right
    # alias_method :width, :cols
    # alias_method :height, :rows

    def initialize(layers)
      @children = []
      layers.each do |layer|
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
      get_dimensions
    end

    def rows
      @right - @left
    end

    def cols
      @bottom - @top
    end

    private

    def get_dimensions
      @left = @children.map(&:left).min
      @top = @children.map(&:top).min
      @bottom = @children.map(&:bottom).max
      @right = @children.map(&:right).max
    end
  end
end