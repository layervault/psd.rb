class PSD
  class Canvas
    attr_reader :width,  :height

    def initialize(node, width, height, color = nil)
      @node = node
      @canvas = ChunkyPNG::Canvas.new(width.to_i, height.to_i, (color || ChunkyPNG::Color::TRANSPARENT))
    end

    def paint_to(base)
      offset_x = PSD::Util.clamp(@node.left.to_i, 0, base.width)
      offset_y = PSD::Util.clamp(@node.top.to_i, 0, base.height)

      height.times do |y|
        width.times do |x|
          base_x = x + offset_x
          base_y = y + offset_y

          next if base_x < 0 || base_y < 0 || base_x >= base.width || base_y >= base.height

          color = Compose.send(
            @node.blending_mode,
            @canvas[x, y],
            base[base_x, base_y],
            opacity: @node.opacity,
            fill_opacity: @node.fill_opacity
          )

          base[base_x, base_y] = color
        end
      end
    end
  end
end