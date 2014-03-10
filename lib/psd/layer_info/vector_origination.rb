require_relative '../layer_info'

class PSD
  class VectorOrigination < LayerInfo
    @key = 'vogk'

    def parse
      @file.seek 8, IO::SEEK_CUR
      @data = Descriptor.new(@file).parse
    end
  end
end