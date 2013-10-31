class PSD
  module Compose
    extend self

    # Normal composition, delegate to ChunkyPNG
    def normal(*args)
      ChunkyPNG::Color.compose(*args)
    end

    def multiply(fg, bg)
      return fg if opaque?(fg) || fully_transparent?(bg)
      return bg if fully_transparent?(fg)

      a_com = int8_mult(0xff - a(fg), a(bg))
      new_r = int8_mult(r(fg), r(bg))
      new_g = int8_mult(g(fg), g(bg))
      new_b = int8_mult(b(fg), b(bg))
      new_a = a(fg) + a_com

      rgba(new_r, new_g, new_b, new_a)
    end

    # If the blend mode is missing, we fall back to normal composition.
    def method_missing(method, *args, &block)
      return ChunkyPNG::Color.send(method, *args) if ChunkyPNG::Color.respond_to?(method)
      normal(*args)
    end
  end
end