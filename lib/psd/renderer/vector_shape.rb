class PSD
  class Renderer
    class VectorShape
      def self.can_render?(canvas)
        return false if canvas.node.vector_mask.nil?
        ([
          :vector_stroke, :vector_stroke_content
        ] & canvas.node.info.keys).length == 2
      end

      DPI = 96.freeze

      def initialize(canvas)
        @canvas = canvas
        @node = @canvas.node
        @path = @node.vector_mask.paths.map(&:to_hash)

        @stroke_data = @node.vector_stroke.data
        @fill_data = @node.vector_stroke_content.data

        @points = []
        @curve_points = []
        @fill_canvas = nil
        @stroke_canvas = nil
      end

      def render_to_canvas!
        PSD.logger.debug "Drawing vector shape to #{@node.name}"

        find_points
        initialize_canvases
        render_shape
        render_stroke
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

        @points.size.times do |i|
          point_a = @points[i]
          point_b = @points[i+1] || @points[0] # wraparound

          b = Bezier.from_path(
            point_a[:anchor],
            point_a[:leaving],
            point_b[:preceding],
            point_b[:anchor]
          )

          b.each_point do |point|
            next if point.nan?
            @curve_points << point
          end
        end
      end

      def initialize_canvases
        @fill_canvas = ChunkyPNG::Canvas.new(@canvas.width, @canvas.height, ChunkyPNG::Color::TRANSPARENT)
        @stroke_canvas = ChunkyPNG::Canvas.new(@canvas.width, @canvas.height, ChunkyPNG::Color::TRANSPARENT)
      end

      def render_shape
        @fill_canvas.polygon(@curve_points, ChunkyPNG::Color::TRANSPARENT, fill_color)
        @canvas.canvas.compose!(@fill_canvas, 0, 0)
      end

      def render_stroke
        @curve_points.each_cons(2) do |p1, p2|
          vector = Vector.new(p1, p2)
          vector.each_point do |p|
            next if p.nan?

            point2_x = if vector.p1.x < vector.p2.x
              p.x - (vector.normal.x * stroke_size)
            else
              p.x + (vector.normal.x * stroke_size)
            end

            point2_y = if vector.p1.y < vector.p2.y
              p.y + (vector.normal.y * stroke_size)
            else
              p.y - (vector.normal.y * stroke_size)
            end

            point2 = Point.new(point2_x, point2_y)

            @stroke_canvas.line(p.x.round, p.y.round, point2.x.round, point2.y.round, stroke_color)
          end
        end

        @canvas.canvas.compose!(@stroke_canvas, 0, 0)
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

      def stroke_size
        @stroke_size ||= (
          if @stroke_data['strokeStyleLineWidth']
            value = @stroke_data['strokeStyleLineWidth'][:value]

            # Convert to pixels
            # if @stroke_data['strokeStyleLineWidth'][:id] == '#Pnt'
            #   value = DPI * value / @stroke_data['strokeStyleResolution']
            # end 

            value.to_i
          else
            1
          end
        )
      end
    end
  end
end