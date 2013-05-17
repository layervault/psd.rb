class PSD::Node
  class Group < PSD::Node
    include PSD::HasChildren
    include PSD::Node::ParseLayers
    attr_reader :name, :top, :left, :bottom, :right

    def initialize(name, layers)
      @name = name
      parse_layers(layers)
      get_dimensions
    end

    def rows
      @right - @left
    end
    alias :height :rows

    def cols
      @bottom - @top
    end
    alias :width :cols

    def to_hash
      {
        name: name,
        height: height,
        width: width,
        children: children.map(&:to_hash)
      }
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