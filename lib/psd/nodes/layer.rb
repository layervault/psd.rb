require 'psd/node'

class PSD
  module Node
    class Layer < PSD::Node::Base
      attr_reader :layer

      [:text, :ref_x, :ref_y, :blending_mode].each do |prop|
        delegate prop, to: :@layer
        delegate "#{prop}=", to: :@layer
      end

      def empty?
        width == 0 || height == 0
      end

      # Exports this layer to a Hash.
      def to_hash
        hash = super.merge({
          type: :layer,
          text: @layer.text,
          ref_x: reference_point.x,
          ref_y: reference_point.y,
          mask: @layer.mask.to_hash,
          image: {
            width: @layer.image.width,
            height: @layer.image.height,
            channels: @layer.channels_info
          },
          layer_comps: {}
        })

        root.psd.layer_comps.each do |comp|
          hash[:layer_comps][comp[:name]] = {
            visible: visible_in_comp?(comp[:id]),
            position: position_in_comp(comp[:id])
          }
        end

        hash
      end

      # In case the layer doesn't have a reference point
      def reference_point
        @layer.reference_point || Struct.new(:x, :y).new(0, 0)
      end

      # If the method is missing, we blindly send it to the layer.
      # The layer handles the case in which the method doesn't exist.
      def method_missing(method, *args, &block)
        @layer.send(method, *args, &block)
      end
    end
  end
end