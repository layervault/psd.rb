require_relative '../layer_info'

class PSD
  class Pattern < LayerInfo
    def self.should_parse?(key)
      return false
      ['Patt', 'Pat2', 'Pat3'].include?(key)
    end

    def parse

    end
  end
end