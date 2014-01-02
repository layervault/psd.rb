class PSD
  class Renderer
    include CanvasManagement

    def initialize(node)
      @root_node = node

      # Our canvas always starts as the full document size because
      # all measurements are relative to this size. We can later crop
      # the image if needed.
      @width = @root_node.document_dimensions[0].to_i
      @height = @root_node.document_dimensions[1].to_i

      @canvas_stack = []
      @node_stack = [@root_node]

      @rendered = false
    end

    def render!
      # Create our base canvas
      create_canvas

      # Begin the rendering process
      execute_pipeline
    end

    def execute_pipeline
      children.each do |child|
        # We skip over hidden nodes. Maybe something configurable in the future?
        next unless child.visible?

        if child.group?
          push_node(child)

          if group_is_passthru?(child)
            execute_pipeline
          else
            create_canvas_for(child)
            execute_pipeline
            pop_canvas
          end

          pop_node and next
        end


      end
    end

    def export
      render! unless @rendered
      PNGExporter.new(@pixel_data)
    end

    private

    def children
      if active_node.layer?
        [active_node]
      else
        active_node.children
      end
    end

    def push_node(node)
      @node_stack << node
    end

    def pop_node
      @node_stack.pop
    end

    def active_node
      @node_stack.last
    end

    def group_is_passthru?(node)
      node.blending_mode == 'passthru'
    end
  end
end