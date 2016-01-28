require 'psd/layer_info'

class PSD
  # The file specification is majorly fucked for this info block. Had to make
  # lots of tweaks.
  class EffectsLayer < LayerInfo
    def self.should_parse?(key)
      key == 'lrFX'
    end

    BEVEL_STYLES = [
      'Outer Bevel',
      'Inner Bevel',
      'Emboss',
      'Pillow Emboss',
      'Stroke Emboss'
    ].freeze

    def parse
      version = @file.read_short
      effects_count = @file.read_short

      @data = {}
      effects_count.times do
        sig = @file.read_string(4)
        if sig != "8BIM"
          PSD.logger.debug "Effect layer signature was not 8BIM, got #{sig}. Skipping."
          return false
        end

        key = @file.read_string(4)
        case key
        when 'cmnS' then common_state
        when 'dsdw' then shadow(:drop_shadow)
        when 'isdw' then shadow(:inner_shadow)
        when 'oglw' then outer_glow
        when 'iglw' then inner_glow
        when 'bevl' then bevel
        when 'sofi' then solid_fill
        end
      end
    end

    private

    # This is the most pointless block of data yet.
    def common_state
      @file.seek 11, IO::SEEK_CUR
      @data[:visible] = true
    end

    def shadow(key)
      @data[key] = {}
      size = @file.read_int

      @data[key][:version] = @file.read_int
      @data[key][:size] = @file.read_short
      @data[key][:spread] = @file.read_int
      @data[key][:angle] = @file.read_int
      @data[key][:distance] = @file.read_int

      # Not sure if Photoshop or the spec is wrong, but somebody done goofed.
      @file.seek 2, IO::SEEK_CUR

      @data[key][:color] = @file.read_space_color

      @file.seek 4, IO::SEEK_CUR # blend mode sig
      @data[key][:blend_mode] = @file.read_string(4)
      @data[key][:enabled] = @file.read_boolean
      @data[key][:use_global_light] = @file.read_boolean
      @data[key][:opacity] = (255.0 / @file.read_byte).round

      if size == 51
        @data[key][:native_color] = @file.read_space_color
      end
    end

    def outer_glow
      @data[:outer_glow] = {}
      size = @file.read_int

      @data[:outer_glow][:version] = @file.read_int
      @data[:outer_glow][:size] = @file.read_short
      @data[:outer_glow][:spread] = @file.read_int
      @file.seek 2, IO::SEEK_CUR

      @data[:outer_glow][:color] = @file.read_space_color

      @file.seek 4, IO::SEEK_CUR # blend sig
      @data[:outer_glow][:blend_mode] = @file.read_string(4)
      @data[:outer_glow][:enabled] = @file.read_boolean
      @data[:outer_glow][:opacity] = (255.0 / @file.read_byte).round

      if size ==42
        @data[:outer_glow][:native_color] = @file.read_space_color
      end
    end

    def inner_glow
      @data[:inner_glow] = {}
      size = @file.read_int

      @data[:inner_glow][:version] = @file.read_int
      @data[:inner_glow][:size] = @file.read_short
      @data[:inner_glow][:spread] = @file.read_int
      @file.seek 2, IO::SEEK_CUR

      @data[:inner_glow][:color] = @file.read_space_color

      @file.seek 4, IO::SEEK_CUR # blend sig
      @data[:inner_glow][:blend_mode] = @file.read_string(4)
      @data[:inner_glow][:enabled] = @file.read_boolean
      @data[:inner_glow][:opacity] = (255.0 / @file.read_byte).round

      if @data[:inner_glow][:version] == 2
        @data[:inner_glow][:invert] = @file.read_boolean
        @data[:inner_glow][:native_color] = @file.read_space_color
      end
    end

    def bevel
      @data[:bevel] = {}
      size = @file.read_int

      @data[:bevel][:version] = @file.read_int

      # Okay somebody really goofed, this is super weird.
      @data[:bevel][:angle] = @file.read_short
      @file.seek 2, IO::SEEK_CUR
      @data[:bevel][:size] = @file.read_short
      @file.seek 2, IO::SEEK_CUR
      @data[:bevel][:soften] = @file.read_short
      @file.seek 2, IO::SEEK_CUR

      @file.seek 4, IO::SEEK_CUR
      @data[:bevel][:highlight_blend] = @file.read_string(4)

      @file.seek 4, IO::SEEK_CUR
      @data[:bevel][:shadow_blend] = @file.read_string(4)

      @data[:bevel][:highlight_color] = @file.read_space_color
      @data[:bevel][:shadow_color] = @file.read_space_color

      @data[:bevel][:style_id] = @file.read_byte
      @data[:bevel][:style] = BEVEL_STYLES[@data[:bevel][:style_id]]

      @data[:bevel][:highlight_opacity] = @file.read_byte
      @data[:bevel][:shadow_opacity] = @file.read_byte
      @data[:bevel][:enabled] = @file.read_boolean
      @data[:bevel][:use_global_light] = @file.read_boolean
      @data[:bevel][:direction] = @file.read_byte == 0 ? 'Up' : 'Down'

      if @data[:bevel][:version] == 2
        @data[:bevel][:real_highlight_color] = @file.read_space_color
        @data[:bevel][:real_shadow_color] = @file.read_space_color
      end
    end

    def solid_fill
      @data[:solid_fill] = {}
      @file.seek 4, IO::SEEK_CUR

      @data[:solid_fill][:version] = @file.read_int

      @file.seek 4, IO::SEEK_CUR
      @data[:solid_fill][:blend_mode] = @file.read_string(4)

      @data[:solid_fill][:color] = @file.read_space_color
      @data[:solid_fill][:opacity] = (255.0 / @file.read_byte).round
      @data[:solid_fill][:enabled] = @file.read_boolean
      @data[:solid_fill][:native_color] = @file.read_space_color
    end
  end
end
