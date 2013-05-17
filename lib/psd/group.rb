class PSD
  class Group < Node
    include PSD::HasChildren
    attr_reader :top, :left, :bottom, :right
    alias_method :width, :cols
    alias_method :height, :rows

    def initialize(layers)
      super(layers)
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