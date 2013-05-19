# Internal structure to help us build trees of a Photoshop documents
class PSD
  class Node
    attr_accessor :parent, :children

    def initialize(layers=[])
      @children = []
      layers.each do |layer|
        layer.parent = self
        @children << layer
      end
    end

    def children_at_path(path, opts={})
      path = path.split('/').delete_if { |p| p == "" } unless path.is_a?(Array)

      query = path.shift
      matches = children.select do |c|
        if opts[:case_sensitive]
          c.name == query
        else
          c.name.downcase == query.downcase
        end
      end

      if path.length == 0
        return matches
      else
        return matches.map { |m| m.children_at_path(path, opts) }.flatten
      end
    end
  end
end