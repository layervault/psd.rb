 class PSD
  class Node
    module BuildPreview
      def to_png
        PSD::Renderer.new(self).to_png
      end

      def save_as_png(output)
        to_png.save(output)
      end
    end
  end
end
