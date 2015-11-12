require 'psd/layer_info'

class PSD
  class BlackWhite < LayerInfo
    def self.should_parse?(key)
      key == 'blwh'
    end

    attr_reader :red, :yellow, :green, :cyan, :blue, :magenta
    attr_reader :tint, :tint_color, :preset_id, :preset_name

    def parse
      @file.seek 4, IO::SEEK_CUR
      @data = Descriptor.new(@file).parse

      @red = @data['Rd  ']
      @yellow = @data['Yllw']
      @green = @data['Grn ']
      @cyan = @data['Cyn ']
      @blue = @data['Bl  ']
      @magenta = @data['Mgnt']
      @tint = @data['useTint']
      @tint_color = {
        red: @data['tintColor']['Rd  '],
        green: @data['tintColor']['Grn '],
        blue: @data['tintColor']['Bl  ']
      }

      @preset_id = @data['bwPresetKind']
      @preset_name = @data['blackAndWhitePresetFileName']
    end
  end
end
