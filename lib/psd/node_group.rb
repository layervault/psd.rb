require_relative 'node'

class PSD
  module Node
    # Represents a group, or folder, in the PSD document. It can have
    # zero or more children nodes.
    class Group < PSD::Node::Base
      def passthru_blending?
        blending_mode == 'passthru'
      end

      def empty?
        children.each do |child|
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
    end
  end
end
