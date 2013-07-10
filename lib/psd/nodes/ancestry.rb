class PSD
  class Node
    module Ancestry
      # Returns the root node
      def root
        return self if is_root?
        return parent.root
      end

      # Is this node the root node?
      def root?
        self.is_a?(PSD::Node::Root)
      end
      alias :is_root? :root?

      # Returns all ancestors in the path of this node. This
      # does NOT return the root node.
      def ancestors
        return [] if parent.nil? || parent.is_root?
        return parent.ancestors + [parent]
      end

      def has_children?
        children.length > 0
      end

      def is_childless?
        !has_children?
      end

      def siblings
        return [] if parent.nil?
        parent.children
      end

      def has_siblings?
        siblings.length > 0
      end

      def is_only_child?
        siblings.length == 1
      end

      def descendants
        children + children.map(&:children).flatten
      end

      def subtree
        [self] + descendants
      end

      # Depth from the root node. Root depth is 0.
      def depth
        return ancestors.length + 1
      end

      def method_missing(method, *args, &block)
        test = /^(.+)_(layers|groups)$/.match(method)
        if test
          m = self.respond_to?(test[1]) ? test[1] : "#{test[1]}s"
          self.send(m).select &method("#{test[2]}_only")
        else
          super
        end
      end

      private

      def layers_only(d); d.is_a?(PSD::Node::Layer); end
      def groups_only(d); d.is_a?(PSD::Node::Group); end
    end
  end
end