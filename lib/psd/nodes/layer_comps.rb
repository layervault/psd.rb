class PSD
  module Node
    module LayerComps
      # Given a layer comp ID or name, create a new
      # tree with layer/group visibility altered based on the layer comp.
      def filter_by_comp(id)
        comp = find_comp(id)
        root = PSD::Node::Root.new(psd)
        
        # Force layers to be visible if they are enabled for the comp
        root.descendants.each do |c|
          set_visibility(comp, c) if Resource::Section::LayerComps.visibility_captured?(comp)
          set_position(comp, c) if Resource::Section::LayerComps.position_captured?(comp)

          PSD.logger.debug "#{c.path}: visible = #{c.visible?}, position = #{c.left}, #{c.top}"
        end

        return root
      end

      def visible_in_comp?(id)
        determine_visibility(find_comp(id), self)
      end

      def position_in_comp(id)
        offset = determine_position_offset(find_comp(id), self)
        
        {
          top: top + offset[:y],
          right: right + offset[:x],
          bottom: bottom + offset[:y],
          left: left + offset[:x]
        }
      end

      private

      def find_comp(id)
        comp = if id.is_a?(String)
          psd.layer_comps.select { |c| c[:name] == id }.first
        else
          psd.layer_comps.select { |c| c[:id] == id }.first
        end

        raise "Layer comp not found" if comp.nil?
        comp
      end

      def set_visibility(comp, c)
        c.force_visible = determine_visibility(comp, c)
      end

      def determine_visibility(comp, c)
        visible = true
        found = false

        c
          .metadata
          .data[:layer_comp]['layerSettings'].each do |l|
            visible = l['enab'] if l.has_key?('enab')
            found = true and break if l['compList'].include?(comp[:id])
          end

        found && visible
      end

      def set_position(comp, c)
        offset = determine_position_offset(comp, c)
        
        c.left_offset = offset[:x]
        c.top_offset = offset[:y]
      end

      def determine_position_offset(comp, c)
        x = 0
        y = 0

        c
          .metadata
          .data[:layer_comp]['layerSettings'].each do |l|
            if l.has_key?('Ofst')
              x = l['Ofst']['Hrzn']
              y = l['Ofst']['Vrtc']
            end
            
            break if l['compList'].include?(comp[:id])
          end

        { x: x, y: y }
      end
    end
  end
end