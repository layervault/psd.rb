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

      new_r = int8_mult(r(fg), r(bg))
      new_g = int8_mult(g(fg), g(bg))
      new_b = int8_mult(b(fg), b(bg))
      new_a = a(fg) + int8_mult(0xff - a(fg), a(bg))

      rgba(new_r, new_g, new_b, new_a)
    end

    def screen(fg, bg)
      return fg if opaque?(fg) || fully_transparent?(bg)
      return bg if fully_transparent?(fg)

      new_r = 0xff - int8_mult(0xff - r(fg), 0xff - r(bg))
      new_g = 0xff - int8_mult(0xff - g(fg), 0xff - g(bg))
      new_b = 0xff - int8_mult(0xff - b(fg), 0xff - b(bg))
      new_a = a(fg) + int8_mult(0xff - a(fg), a(bg))

      rgba(new_r, new_g, new_b, new_a)
    end

    # If the blend mode is missing, we fall back to normal composition.
    def method_missing(method, *args, &block)
      return ChunkyPNG::Color.send(method, *args) if ChunkyPNG::Color.respond_to?(method)
      normal(*args)
    end
  end
end