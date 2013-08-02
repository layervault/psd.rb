require 'chunky_png'

class PSD::Image
  module Export
    # PNG image export. This is the default export format.
    module PNG
      # Load the image pixels into a PNG file and return a reference to the
      # data.
      def to_png
        PSD.logger.debug "Beginning PNG export"
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

      # Saves the PNG data to disk.
      def save_as_png(file)
        to_png.save(file, :fast_rgba)
      end
    end
  end
end