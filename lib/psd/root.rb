# Represents the root node of a Photoshop document
class PSD
  class Root < Node
    include PSD::HasChildren

    attr_reader :children

    def initialize(layers)
      super(layers)
    end
  end
end