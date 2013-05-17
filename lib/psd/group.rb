class PSD
  class Group < Node
    include PSD::HasChildren
    attr_reader :top, :left, :bottom, :right

    def initialize(layers)
      @children = []
      layers.each do |layer|
        layer.parent = self
        @children << layer
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
      @left = (@layers.map(&:left) + @groups.map(&:left)).min
      @top = (@layers.map(&:top) + @groups.map(&:top)).min
      @bottom = (@layers.map(&:bottom) + @groups.map(&:bottom)).max
      @right = (@layers.map(&:right) + @groups.map(&:right)).max
    end
  end
end