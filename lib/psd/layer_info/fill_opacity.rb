require_relative '../layer_info'

class PSD
  class FillOpacity < LayerInfo
    @key = 'iOpa'

    attr_reader :enabled

    def parse
      @enabled = @file.read_boolean
    end
  end
end