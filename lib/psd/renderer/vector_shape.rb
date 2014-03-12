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

      DPI = 72.0.freeze

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
        PSD.logger.debug "Beginning vector render for #{@node.name}"

        find_points
        render_shape
      end

      private

      def find_points
        PSD.logger.debug "Formatting vector points..."

        @path.each do |data|
          next unless [1, 2, 4, 5].include? data[:record_type]
          @points << data.tap do |d|
            [:preceding, :anchor, :leaving].each do |type|
              d[type][:horiz] = (d[type][:horiz] * horiz_factor) - @node.left
              d[type][:vert]  = (d[type][:vert] * vert_factor) - @node.top
            end
          end
        end

        PSD.logger.debug "Vector shape has #{@points.size} anchors"

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

      # TODO: stroke alignment
      # Right now we assume the stroke style is always an inside stroke.
      def render_shape
        PSD.logger.debug "Rendering #{@curve_points.size} vector points with cairo"

        points = @curve_points.map(&:to_a)
        output = cairo_image_surface(@canvas.width + stroke_size, @canvas.height + stroke_size) do |cr|
          cr.set_line_join stroke_join
          cr.set_line_cap stroke_cap

          cr.translate stroke_size / 2.0, stroke_size / 2.0

          cairo_path(cr, *(points + [:c]))

          cr.set_source_rgba fill_color
          cr.fill_preserve

          if has_stroke?
            cr.set_source_rgba stroke_color
            cr.set_line_width stroke_size
            cr.stroke
          end
        end

        output.resample_nearest_neighbor!(@canvas.width, @canvas.height)
        @canvas.canvas.compose!(output, 0, 0)
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
              colors['Bl  '] / 255.0,
              @stroke_data['strokeStyleOpacity'][:value] / 100.0
            ]
          else
            [0.0, 0.0, 0.0, 0.0]
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
              colors['Bl  '] / 255.0,
              @stroke_data['strokeStyleOpacity'][:value] / 100.0
            ]
          else
            [0.0, 0.0, 0.0, 0.0]
          end
        )
      end

      def stroke_size
        @stroke_size ||= (
          if @stroke_data['strokeStyleLineWidth']
            value = @stroke_data['strokeStyleLineWidth'][:value]

            # Convert to pixels
            if @stroke_data['strokeStyleLineWidth'][:id] == '#Pnt'
              value = @stroke_data['strokeStyleResolution'] * value / 72.27
            end

            value.to_i
          else
            0
          end
        )
      end

      def stroke_cap
        @stroke_cap ||= (
          if @stroke_data['strokeStyleLineCapType']
            case @stroke_data['strokeStyleLineCapType']
            when 'strokeStyleButtCap' then Cairo::LINE_CAP_BUTT
            when 'strokeStyleRoundCap' then Cairo::LINE_CAP_ROUND
            when 'strokeStyleSquareCap' then Cairo::LINE_CAP_SQUARE
            end
          else
            Cairo::LINE_CAP_BUTT
          end
        )
      end

      def stroke_join
        @stroke_join ||= (
          if @stroke_data['strokeStyleLineJoinType']
            case @stroke_data['strokeStyleLineJoinType']
            when 'strokeStyleMiterJoin' then Cairo::LINE_JOIN_MITER
            when 'strokeStyleRoundJoin' then Cairo::LINE_JOIN_ROUND
            when 'strokeStyleBevelJoin' then Cairo::LINE_JOIN_BEVEL
            end
          else
            Cairo::LINE_JOIN_MITER
          end
        )
      end

      def has_stroke?
        stroke_size > 0
      end
    end
  end
end