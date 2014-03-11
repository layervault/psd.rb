class PSD
  class Renderer
    class Vector
      include Enumerable

      attr_reader :p1, :p2

      def initialize(p1, p2)
        @p1 = p1
        @p2 = p2
      end

      def slope
        @slope ||= (p2.y - p1.y) / (p2.x - p1.x)
      end

      def intercept
        @intercept ||= (@p1.y - (slope * @p1.x))
      end
      alias_method :y_intercept, :intercept

      def fx(x)
        Point.new(x, (slope * x) + intercept)
      end

      def normal
        @normal ||= (
          normal_x = (@p2.x - @p1.x) / length
          normal_y = (@p2.y - @p1.y) / length

          Point.new(normal_x, normal_y)
        )
      end

      def length
        @length ||= Math.sqrt((@p2.x - @p1.x)**2 + (@p2.y - @p1.y)**2)
      end

      def each
        (x_min..x_max).each do |x|
          yield fx(x)
        end
      end
      alias_method :each_point, :each

      def x_min
        [@p1.x, @p2.x].min.to_i
      end

      def x_max
        [@p1.x, @p2.x].max.to_i
      end
    end
  end
end