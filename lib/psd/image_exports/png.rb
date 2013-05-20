require 'chunky_png'

# PNG image export
# This also happens to be the default
class PSD::Image
  module Export
    module PNG
      def to_png
        png = ChunkyPNG::Image.new(width, height, ChunkyPNG::Color::TRANSPARENT)

        i = 0
        height.times do |y|
          width.times do |x|
            png[x,y] = ChunkyPNG::Color.rgba(
              @pixel_data[i],
              @pixel_data[i+1],
              @pixel_data[i+2],
              @pixel_data[i+3]
            )

            i += 4
          end
        end

        png
      end
      alias :export :to_png

      def save_as_png(file)
        to_png.save(file)
      end
    end
  end
end