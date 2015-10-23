require 'psd/layer_info'

class PSD
  class Exposure < LayerInfo
    def self.should_parse?(key)
      key == 'expA'
    end

    attr_reader :exposure, :offset, :gamma

    def parse
      @file.seek 2, IO::SEEK_CUR

      # Why this shit is big endian is beyond me. Thanks Adobe.
      @exposure = @file.read(4).unpack('g')[0]
      @offset = @file.read(4).unpack('g')[0]
      @gamma = @file.read(4).unpack('g')[0]
    end
  end
end
