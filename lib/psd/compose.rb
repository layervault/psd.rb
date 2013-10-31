class PSD
  module Compose
    extend self

    # Normal composition, delegate to ChunkyPNG
    def normal(*args)
      ChunkyPNG::Color.compose(*args)
    end

    # If the blend mode is missing, we fall back to normal composition.
    def method_missing(method, *args, &block)
      normal(*args)
    end
  end
end