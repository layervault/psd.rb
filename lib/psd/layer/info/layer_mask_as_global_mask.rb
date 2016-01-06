require 'psd/layer_info'

class PSD
  class LayerMaskAsGlobalMask < LayerInfo
    def self.should_parse?(key)
      key == 'lmgm'
    end

    def parse
      # The PSD file spec appears to be wrong here. It says that a value
      # of 1 means that the mask is unlinked, but in reality it appears that
      # a value of 0 means it's unlinked. It also looks like mask-linked layers
      # don't even have this info key, so there's that.
      @linked = @file.read_boolean
    end

    def linked?
      @linked
    end

    def unlinked?
      !@linked
    end
  end
end
