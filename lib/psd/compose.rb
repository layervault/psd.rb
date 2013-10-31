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

    def overlay(fg, bg)
      return fg if opaque?(fg) || fully_transparent?(bg)
      return bg if fully_transparent?(fg)

      if r(bg) > 128
        new_r = 0xff - 2 * int8_mult(255 - r(fg), 255 - r(bg))
      else
        new_r = 2 * int8_mult(r(fg), r(bg))
      end

      if g(bg) > 128
        new_g = 0xff - 2 * int8_mult(255 - g(fg), 255 - g(bg))
      else
        new_g = 2 * int8_mult(g(fg), g(bg))
      end

      if b(bg) > 128
        new_b = 0xff - 2 * int8_mult(255 - b(fg), 255 - b(bg))
      else
        new_b = 2 * int8_mult(b(fg), b(bg))
      end

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