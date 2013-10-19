class PSD
  class Layer
    module Helpers
      # Does this layer represent the start of a folder section?
      def folder?
        if @adjustments.has_key?(:section_divider)
          @adjustments[:section_divider].is_folder
        else
          name == "<Layer group>"
        end
      end

      # Does this layer represent the end of a folder section?
      def folder_end?
        if @adjustments.has_key?(:section_divider)
          @adjustments[:section_divider].is_hidden
        else
          name == "</Layer group>"
        end
      end

      # Is this layer visible?
      def visible?
        @visible
      end

      # Is this layer hidden?
      def hidden?
        !@visible
      end

      # Helper that exports the text data in this layer, if any.
      def text
        return nil unless @adjustments[:type]
        @adjustments[:type].to_hash
      end
    end
  end
end