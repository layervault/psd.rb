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
      @left = @chilren.map(&:left).min
      @top = @chilren.map(&:top).min
      @bottom = @chilren.map(&:bottom).max
      @right = @chilren.map(&:right).max
    end
  end
end