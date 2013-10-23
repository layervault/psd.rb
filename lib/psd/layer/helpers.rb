class PSD
  class Layer
    module Helpers
      # Does this layer represent the start of a folder section?
      def folder?
        if info.has_key?(:section_divider)
          info[:section_divider].is_folder
        elsif info.has_key?(:nested_section_divider)
          info[:nested_section_divider].is_folder
        else
          name == "<Layer group>"
        end
      end

      # Does this layer represent the end of a folder section?
      def folder_end?
        if info.has_key?(:section_divider)
          info[:section_divider].is_hidden
        elsif info.has_key?(:nested_section_divider)
          info[:nested_section_divider].is_hidden
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
        return nil unless info[:type]
        info[:type].to_hash
      end

      def layer_type
        return 'normal' unless info.has_key?(:section_divider)
        info[:section_divider].layer_type
      end

      def fill_opacity
        return nil unless info.has_key?(:fill_opacity)
        info[:fill_opacity].enabled
      end
    end
  end
end