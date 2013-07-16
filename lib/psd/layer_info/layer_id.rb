class PSD
  class LayerID < LayerInfo
    @key = 'lyid'

    attr_reader :id

    def parse
      @id = @file.read_int
    end
  end
end