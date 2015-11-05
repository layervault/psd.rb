class PSD
  module Node
    # Locking is inherited by descendants, but Photoshop doesn't reflect
    # this directly in the file, so we have to recursively traverse the
    # ancestry tree to make sure an ancestor isn't locked.
    module Locking
      def all_locked?
        return true if layer.all_locked?
        return false if parent.root?
        return parent.all_locked?
      end

      def any_locked?
        position_locked? || composite_locked? || transparency_locked?
      end

      def position_locked?
        return true if layer.position_locked?
        return false if parent.root?
        return parent.position_locked?
      end

      def composite_locked?
        return true if layer.composite_locked?
        return false if parent.root?
        return parent.composite_locked?
      end

      def transparency_locked?
        return true if layer.transparency_locked?
        return false if parent.root?
        return parent.transparency_locked?
      end
    end
  end
end
