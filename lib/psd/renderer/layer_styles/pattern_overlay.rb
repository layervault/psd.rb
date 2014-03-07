class PSD
  class LayerStyles
    class PatternOverlay
      def self.should_apply?(data)
        puts data.inspect
        data.has_key?('')
      end
    end
  end
end