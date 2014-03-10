class PSD
  class Renderer
    class Bezier
      def self.from_path(a, b, c, d)
        self.new(
          [a[:horiz], a[:vert]],
          [b[:horiz], b[:vert]],
          [c[:horiz], c[:vert]],
          [d[:horiz], d[:vert]]
        )
      end

      def initialize(start_point, ctrl1, ctrl2, end_point)
        @a = Vector.new(*start_point)
        @b = Vector.new(*ctrl1)
        @c = Vector.new(*ctrl2)
        @d = Vector.new(*end_point)
      end

      # Adapted from http://cubic.org/docs/bezier.htm
      def point_at(t)
        ab = @a.interpolate(@b, t)
        bc = @b.interpolate(@c, t)
        cd = @c.interpolate(@d, t)
        abbc = ab.interpolate(bc, t)
        bccd = bc.interpolate(cd, t)
        abbc.interpolate(bccd, t)
      end
    end
  end
end