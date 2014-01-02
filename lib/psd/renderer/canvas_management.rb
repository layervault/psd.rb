class PSD
  class Renderer
    module CanvasManagment
      def active_canvas
        @canvas_stack.last
      end

      def create_canvas(width=@width, height=@height)
        push_canvas Canvas.new(width, height)
      end

      def create_canvas_for(node)
        create_canvas node.width.to_i, node.height.to_i
      end

      def push_canvas(canvas)
        @canvas_stack << canvas
      end

      def pop_canvas
        @canvas_stack.pop
      end
    end
  end
end