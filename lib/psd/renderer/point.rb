class PSD
  class Renderer
    class Point
      attr_accessor :x, :y

      def initialize(x, y)
        @x = x.to_f
        @y = y.to_f
      end

      def interpolate(b, t)
        self.class.new(
          x + (b.x - x) * t,
          y + (b.y - y) * t
        )
      end

      def nan?
        @x.nan? || @y.nan?
      end

      def to_a
        [@x, @y]
      end

      def ==(other)
        @x == other.x && @y == other.y
      end
    end
  end
end