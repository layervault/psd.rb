require_relative './cairo_helpers'

class PSD
  class Renderer
    class VectorShape
      include CairoHelpers

      def self.can_render?(canvas)
        canvas.opts[:render_vectors] && !canvas.node.vector_mask.nil?
      end

      DPI = 72.0.freeze

      def initialize(canvas)
        @canvas = canvas
        @node = @canvas.node
        @path = @node.vector_mask.paths.map(&:to_hash)

        @stroke_data = @node.vector_stroke ? @node.vector_stroke.data : {}
        @fill_data = @node.vector_stroke_content ? @node.vector_stroke_content.data : {}

        @paths = []
      end

      def render!
        PSD.logger.debug "Beginning vector render for #{@node.name}"

        find_points
        render_shapes
      end

      private

      def find_points
        PSD.logger.debug "Formatting vector points..."

        cur_path = nil
        @path.each do |data|
          next if [6, 7, 8].include? data[:record_type]
          
          if [0, 3].include? data[:record_type]
            @paths << cur_path
            cur_path = []
            next
          end

          cur_path << data.tap do |d|
            if [1, 2, 4, 5].include? data[:record_type]
              [:preceding, :anchor, :leaving].each do |type|
                d[type][:horiz] = (d[type][:horiz] * horiz_factor) - @node.left
                d[type][:vert]  = (d[type][:vert] * vert_factor) - @node.top
              end
            end
          end
        end

        @paths << cur_path
        @paths.compact!

        PSD.logger.debug "Vector shape has #{@paths.size} path(s)"
      end

      # TODO: stroke alignment
      # Right now we assume the stroke style is always a overlap stroke.
      def render_shapes
        PSD.logger.debug "Rendering #{@paths.size} vector paths with cairo"

        cairo_image_surface(@canvas.width + stroke_size, @canvas.height + stroke_size) do |cr|
          cr.set_fill_rule Cairo::FILL_RULE_EVEN_ODD
          cr.set_line_join stroke_join
          cr.set_line_cap stroke_cap

          cr.translate stroke_size / 2.0, stroke_size / 2.0

          @paths.each do |path|
            cr.move_to path[0][:anchor][:horiz], path[0][:anchor][:vert]

            path.size.times do |i|
              point_a = path[i]
              point_b = path[i+1] || path[0]

              cr.curve_to(
                point_a[:leaving][:horiz],
                point_a[:leaving][:vert],
                point_b[:preceding][:horiz],
                point_b[:preceding][:vert],
                point_b[:anchor][:horiz],
                point_b[:anchor][:vert]
              )
            end

            cr.close_path if path.last[:closed]
          end

          cr.set_source_rgba fill_color
          cr.fill_preserve

          if has_stroke?
            cr.set_source_rgba stroke_color
            cr.set_line_width stroke_size
            cr.stroke
          end
        end
      end

      # For debugging purposes only
      def draw_debug(canvas)
        @paths.each do |path|
          path.each do |point|
            canvas.circle(point[:anchor][:horiz].to_i, point[:anchor][:vert].to_i, 3, ChunkyPNG::Color::BLACK, ChunkyPNG::Color::BLACK)
            [:leaving, :preceding].each do |type|
              canvas.circle(point[type][:horiz].to_i, point[type][:vert].to_i, 3, ChunkyPNG::Color.rgb(255, 0, 0), ChunkyPNG::Color.rgb(255, 0, 0))
              canvas.line(
                point[:anchor][:horiz].to_i, point[:anchor][:vert].to_i,
                point[type][:horiz].to_i, point[type][:vert].to_i,
                ChunkyPNG::Color::BLACK
              )
            end
          end
        end
      end

      def apply_to_canvas(output)
        # draw_debug(output)
        output.resample_nearest_neighbor!(@canvas.width, @canvas.height)
        @canvas.canvas.compose!(output, 0, 0)
      end

      def formatted_points
        @formatted_points ||= @curve_points.map(&:to_a)
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
          overlay = PSD::LayerStyles::ColorOverlay.for_canvas(@canvas)
          
          if overlay
            [
              overlay.r / 255.0,
              overlay.g / 255.0,
              overlay.b / 255.0,
              overlay.a / 255.0
            ]
          elsif @stroke_data['fillEnabled']
            colors = @fill_data['Clr ']
            [
              colors['Rd  '] / 255.0,
              colors['Grn '] / 255.0,
              colors['Bl  '] / 255.0,
              @stroke_data['strokeStyleOpacity'][:value] / 100.0
            ]
          elsif !@node.solid_color.nil?
            [
              @node.solid_color.r / 255.0,
              @node.solid_color.g / 255.0,
              @node.solid_color.b / 255.0,
              1.0
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