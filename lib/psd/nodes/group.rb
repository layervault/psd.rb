class PSD::Node
  class Group < PSD::Node
    include PSD::HasChildren
    include PSD::Node::ParseLayers
    include PSD::Node::LockToOrigin

    attr_reader :name, :top, :left, :bottom, :right

    def initialize(folder)
      @name = folder[:name]
      @layer = folder[:layer]
      parse_layers(folder[:layers])
      get_dimensions
    end

    def rows
      @right - @left
    end
    alias :height :rows

    def cols
      @bottom - @top
    end
    alias :width :cols

    def translate(x=0, y=0)
      @children.each{ |c| c.translate(x,y) }
    end

    def hide!
      @children.each{ |c| c.hide! }
    end

    def show!
      @children.each{ |c| c.show! }
    end

    def to_hash
      super.merge({
        type: :group,
        visible: visible?,
        children: children.map(&:to_hash)
      })
    end

    def document_dimensions
      @parent.document_dimensions
    end

    private

    def get_dimensions
      @left = @children.map(&:left).min
      @top = @children.map(&:top).min
      @bottom = @children.map(&:bottom).max
      @right = @children.map(&:right).max
    end
  end
end