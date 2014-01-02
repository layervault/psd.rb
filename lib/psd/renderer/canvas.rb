class PSD
  class Canvas
    def initialize(width, height, color = nil)
      @canvas = ChunkyPNG::Canvas.new(width.to_i, height.to_i, (color || ChunkyPNG::Color::TRANSPARENT))
    end
  end
end