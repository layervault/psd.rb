require_relative 'node'

class PSD
  module Node
    class Layer < PSD::Node::Base
      attr_reader :layer

      [:text, :ref_x, :ref_y].each do |prop|
        delegate prop, to: :@layer
        delegate "#{prop}=", to: :@layer
      end

      def empty?
        width == 0 || height == 0
      end

      # Exports this layer to a Hash.
      def to_hash
        super.merge({
          type: :layer,
          text: @layer.text,
          ref_x: @layer.reference_point.x,
          ref_y: @layer.reference_point.y,
          mask: @layer.mask.to_hash,
          image: {
            width: @layer.image.width,
            height: @layer.image.height,
            channels: @layer.channels_info
          }
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