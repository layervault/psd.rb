class PSD
  class Renderer
    # From http://www.hokstad.com/simple-drawing-in-ruby-with-cairo
    module CairoHelpers
      def cairo_image_surface(w, h, bg=nil)
        surface = Cairo::ImageSurface.new(w, h)
        cr = Cairo::Context.new(surface)

        if bg
          cr.set_source_rgba(*bg)
          cr.paint
        end

        yield cr
      end

      def cairo_path(cr, *pairs)
        first = true
        pairs.each do |cmd| 
          if cmd == :c
            cr.close_path
            first = true
          elsif first
            cr.move_to(*cmd)
            first = false
          else
            cr.line_to(*cmd)
          end 
        end
      end
    end
  end
end