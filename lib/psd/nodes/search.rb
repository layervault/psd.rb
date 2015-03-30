class PSD
  module Node
    module Search
      def find_by_id(id)
        subtree.select { |n| n.id == id }.first
      end

      # Searches the tree structure for a node at the given path. The path is
      # defined by the layer/folder names. Because the PSD format does not
      # require unique layer/folder names, we always return an array of all
      # found nodes.
      def children_at_path(path, opts={})
        path = path.split('/').delete_if { |p| p == "" } unless path.is_a?(Array)

        path = path.dup
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
          return matches.map { |m| m.children_at_path(path.dup, opts) }.flatten
        end
      end
      alias :children_with_path :children_at_path
    end
  end
end
