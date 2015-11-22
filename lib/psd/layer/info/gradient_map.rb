require 'psd/layer_info'

class PSD
  class GradientMap < LayerInfo
    def self.should_parse?(key)
      key == 'grdm'
    end

    attr_reader :reverse, :dither, :name, :color_stops, :transparency_stops,
                :interpolation, :mode, :random_seed, :showing_transparency, :using_vector_color,
                :roughness_factor, :color_model, :minimum_color, :maximum_color

    def parse
      # Version
      @file.seek 2, IO::SEEK_CUR

      @reverse = @file.read_boolean
      @dither = @file.read_boolean

      @name = @file.read_unicode_string

      color_stops = @file.read_short
      @color_stops = color_stops.times.map do
        color = {
          location: @file.read_int,
          midpoint: @file.read_int,
          color: @file.read_space_color
        }

        # Mystery padding
        @file.seek 2, IO::SEEK_CUR
        color
      end

      transparency_stops = @file.read_short
      @transparency_stops = transparency_stops.times.map do
        {
          location: @file.read_int,
          midpoint: @file.read_int,
          opacity: @file.read_short
        }
      end

      expansion_count = @file.read_short
      if expansion_count > 0
        @interpolation = @file.read_short
        length = @file.read_short
        if length >= 32
          @mode = @file.read_short
          @random_seed = @file.read_int
          @showing_transparency = @file.read_short > 0
          @using_vector_color = @file.read_short > 0
          @roughness_factor = @file.read_int
          
          @color_model = @file.read_short
          @minimum_color = 4.times.map do
            @file.read_short >> 8
          end

          @maximum_color = 4.times.map do
            @file.read_short >> 8
          end
        end
      end

      @file.seek 2, IO::SEEK_CUR
    end
  end
end
