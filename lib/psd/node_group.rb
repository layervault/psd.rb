require_relative 'node'

class PSD::Node
  # Represents a group, or folder, in the PSD document. It can have
  # zero or more children nodes.
  class Group < PSD::Node
    include PSD::HasChildren

    # Parses the descendant tree structure and figures out the bounds
    # of the layers within this folder.
    def initialize(folder)
      @layer = folder[:layer]
      
      super(folder[:layers])
      get_dimensions
    end

    def passthru_blending?
      blending_mode == 'passthru'
    end

    def empty?
      @children.each do |child|
        return false unless child.empty?
      end
      
      return true
    end

    # Export this layer and it's children to a hash recursively.
    def to_hash
      super.merge({
        type: :group,
        children: children.map(&:to_hash)
      })
    end

    # If the method is missing, we blindly send it to the layer.
    # The layer handles the case in which the method doesn't exist.
    def method_missing(method, *args, &block)
      @layer.send(method, *args, &block)
    end

    private

    def get_dimensions
      children = @children.reject(&:empty?)
      @left = children.map(&:left).min || 0
      @top = children.map(&:top).min || 0
      @bottom = children.map(&:bottom).max || 0
      @right = children.map(&:right).max || 0
    end
  end
end
