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

      attr_reader :a, :b, :c, :d

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

      def left_bound
        @left_bound ||= [@a.x, @d.x].min.round
      end

      def right_bound
        @right_bound ||= [@a.x, @d.x].max.round
      end

      def each_point
        (left_bound..right_bound).each do |x|
          yield point_at t_for_x(x)
        end
      end

      private

      def t_for_x(x)
        (x - left_bound).to_f / (right_bound - left_bound).to_f
      end
    end
  end
end