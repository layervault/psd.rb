class PSD
  class Renderer
    module CanvasManagment
      def active_canvas
        @canvas_stack.last
      end

      def create_group_canvas(node, width=@width, height=@height)
        push_canvas Canvas.new(node, width, height)
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