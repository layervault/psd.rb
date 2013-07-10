class PSD
  class TypeTool
    def initialize(file, length)
      @file = file
      @length = length
      @data = {}
    end

    def parse
      version = @file.read_short
      parse_transform_info

      text_version = @file.read_short
      descriptor_version = @file.read_int

      @data[:text] = Descriptor.new(@file).parse
      @data[:text]['EngineData'].encode!('UTF-8', 'MacRoman').delete!("\000")

      warpVersion = @file.read_short
      descriptor_version = @file.read_int

      @data[:warp] = Descriptor.new(@file).parse
      [:left, :top, :right, :bottom].each do |pos|
        @data[pos] = @file.read_double
      end

      return self
    end

    # NOTE: This is hacky, gross, and dirty. We need a real PSDShittyMarkup™ parser.
    def text_value
      /\/Text \(˛ˇ(.*)\r\)$/.match(engine_data)[1]
    end
    alias :to_s :text_value

    def engine_data
      @data[:text]['EngineData']
    end

    def to_hash
      {
        value:   text_value,
        left:   left,
        top:    top,
        right:  right,
        bottom: bottom
      }
    end

    def method_missing(method, *args, &block)
      return @data[method] if @data.has_key?(method)
      return super
    end

    private

    def parse_transform_info
      @data[:transform] = {}
      [:xx, :xy, :yx, :yy, :tx, :ty].each do |t|
        @data[:transform][t] = @file.read_double
      end
    end
  end
end