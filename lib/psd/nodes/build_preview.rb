 class PSD
  module Node
    module BuildPreview
      def renderer(opts = {})
        PSD::Renderer.new(self, opts)
      end

      def to_png
        @png ||= renderer(render_hidden: self.layer?).to_png
      end

      def save_as_png(output)
        to_png.save(output)
      end
    end
  end
end
