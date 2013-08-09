class PSD
  class Node
    module Search
      # Searches the tree structure for a node at the given path. The path is
      # defined by the layer/folder names. Because the PSD format does not
      # require unique layer/folder names, we always return an array of all
      # found nodes.
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

      def filter_by_comp(id)
        if id.is_a?(String)
          comp = psd.layer_comps.select { |c| c[:name] == id }.first
          raise "Layer comp not found" if comp.nil?

          id = comp[:id]
        elsif id == :last
          id = 0
        end

        root = PSD::Node::Root.new(psd)
        root.children = root
          .descendants
          .select { |l|
            l.adjustments[:metadata].data[:layer_comp]['layerSettings'].select { |s|
              next(false) unless s.has_key?('compList')
              next(false) unless s.has_key?('enab') && s['enab'] == true

              s['compList'].include?(id)
            }.size > 0
          }

        return root
      end
    end
  end
end