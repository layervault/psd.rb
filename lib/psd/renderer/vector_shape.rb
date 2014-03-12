require_relative './cairo_helpers'

class PSD
  class Renderer
    class VectorShape
      include CairoHelpers

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
        render_shape
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

      def render_shape
        output = cairo_image_surface(@node.root.width, @node.root.height) do |cr, output|
          cr.set_line_join Cairo::LINE_JOIN_ROUND
          cr.set_line_cap Cairo::LINE_CAP_ROUND
          cr.translate @node.left, @node.top

          points = @curve_points.map(&:to_a)
          cairo_path(cr, *(points + [:c]))

          cr.set_source_color fill_color
          cr.fill_preserve

          cr.set_source_color stroke_color
          cr.set_line_width stroke_size
          cr.stroke
        end

        output.save('./test.png')
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
            [
              colors['Rd  '] / 255.0,
              colors['Grn '] / 255.0,
              colors['Bl  '] / 255.0
            ]
          else
            [0.0, 0.0, 0.0]
          end
        )
      end

      def fill_color
        @fill_color ||= (
          if @stroke_data['fillEnabled']
            colors = @fill_data['Clr ']
            [
              colors['Rd  '] / 255.0,
              colors['Grn '] / 255.0,
              colors['Bl  '] / 255.0
            ]
          else
            [0.0, 0.0, 0.0]
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