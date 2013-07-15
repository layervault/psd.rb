class PSD
  class LayerNameSource < LayerInfo
    @key = 'lnsr'
    
    def parse
      @data = @file.read_int
      return self
    end
  end
end