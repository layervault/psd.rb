class PSD
  module HasChildren
    def groups
      @children.select{ |c| c.is_a?(PSD::Group) }
    end

    def layers
      @children.select{ |c| c.is_a?(PSD::Layer) }
    end
  end
end