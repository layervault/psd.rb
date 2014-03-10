class PSD
  class Renderer
    class VectorShape
      def self.can_render?(canvas)
        return false if canvas.node.vector_mask.nil?
        ([
          :vector_stroke, :vector_stroke_content
        ] & canvas.node.info.keys).length == 2
      end

      def initialize(canvas)
        @canvas = canvas
        @node = @canvas.node
        @path = @node.vector_mask.paths.map(&:to_hash)

        @stroke_data = @node.vector_stroke.data
        @fill_data = @node.vector_stroke_content.data

        @points = []
      end

      def render_to_canvas!
        PSD.logger.debug "Drawing vector shape to #{@node.name}"

        find_points
        render_curves
      end

      private

      def find_points
        @path.each do |data|
          next unless [1, 2, 4, 5].include? data[:record_type]
          @points << data.tap do |d|
            [:preceding, :anchor, :leaving].each do |type|
              d[type][:horiz] = (d[type][:horiz] * horiz_factor) - @node.left
              d[type][:vert]  = (d[type][:vert] * vert_factor) - @node.top
            end
          end
        end

        PSD.logger.debug "Shape has #{@points.size} points"
      end

      def render_curves
        @points.size.times do |i|
          point_a = @points[i]
          point_b = @points[i+1] || @points[0] # wraparound

          b = Bezier.from_path(
            point_a[:anchor],
            point_a[:leaving],
            point_b[:preceding],
            point_b[:anchor]
          )

          b.draw_points(@canvas.canvas)

          curve_points = []
          b.each_point do |point|
            curve_points << point
          end

          curve_points.each_cons(2) do |p1, p2|
            @canvas.canvas.line(p1.x.round, p1.y.round, p2.x.round, p2.y.round, ChunkyPNG::Color::BLACK, false)
          end
        end
      end

      def horiz_factor
        @horiz_factor ||= @node.root.width.to_f
      end

      def vert_factor
        @vert_factor ||= @node.root.height.to_f
      end

      def stroke_color
        @stroke_color ||= (
          if @stroke_data['strokeEnabled']
            colors = @stroke_data['strokeStyleContent']['Clr ']
            ChunkyPNG::Color.rgb(
              colors['Rd  '].to_i,
              colors['Grn '].to_i,
              colors['Bl  '].to_i
            )
          else
            ChunkyPNG::Color::TRANSPARENT
          end
        )
      end

      def fill_color
        @fill_color ||= (
          if @stroke_data['fillEnabled']
            colors = @fill_data['Clr ']
            ChunkyPNG::Color.rgb(
              colors['Rd  '].to_i,
              colors['Grn '].to_i,
              colors['Bl  '].to_i
            )
          else
            ChunkyPNG::Color::TRANSPARENT
          end
        )
      end
    end
  end
end