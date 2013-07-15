class PSD
  class ObjectEffects < LayerAdjustment
    def parse
      version = @file.read_int
      descriptor_version = @file.read_int

      @data = Descriptor.new(@file).parse

      return self
    end
  end
end