class PSD
  class Node
    module BuildPreview
      include PSD::Image::Export::PNG

      alias :orig_to_png :to_png
      def to_png
        width, height = document_dimensions
        png = ChunkyPNG::Canvas.new(width.to_i, height.to_i, ChunkyPNG::Color::TRANSPARENT)
        
        build_pixel_data(png)
        png
      end

      def build_pixel_data(png)
        children.reverse.each do |c|
          if c.group?
            c.build_pixel_data(png)
          else
            png.compose! c.image.to_png, c.left.to_i, c.top.to_i
          end
        end
      end
    end
  end
end