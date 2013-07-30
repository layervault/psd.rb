# encoding: UTF-8
require_relative '../layer_info'

class PSD
  # Parses and provides information about text areas within layers in
  # the document.
  class TypeTool < LayerInfo
    @key = 'TySh'
    
    # Parse all of the text data in the layer.
    def parse
      version = @file.read_short
      parse_transform_info

      text_version = @file.read_short
      descriptor_version = @file.read_int

      @data[:text] = Descriptor.new(@file).parse
      @data[:text]['EngineData']
        .encode!('UTF-8', 'MacRoman')
        .delete!("\000")

      @data[:engine_data] = nil
      begin
        parser.parse!
        @data[:engine_data] = parser.result
      rescue Exception => e
        puts e.message
      end

      warpVersion = @file.read_short
      descriptor_version = @file.read_int

      @data[:warp] = Descriptor.new(@file).parse
      [:left, :top, :right, :bottom].each do |pos|
        @data[pos] = @file.read_int
      end

      return self
    end

    # Extracts the text within the text area. In the event that psd-enginedata fails
    # for some reason, we attempt to extract the text using some rough regex.
    def text_value
      if engine_data.nil?
        # Something went wrong, lets hack our way through.
        /\/Text \(˛ˇ(.*)\)$/.match(@data[:text]['EngineData'])[1].gsub /\r/, "\n"
      else
        engine_data.EngineDict.Editor.Text
      end
    end
    alias :to_s :text_value

    # Gets all of the basic font information for this text area. This assumes that
    # the first font is the only one you want.
    def font
      {
        name: fonts.first,
        sizes: sizes,
        colors: colors,
        css: parser.to_css
      }
    end

    # Returns all fonts listed for this layer, since fonts are defined on a 
    # per-character basis.
    def fonts
      return [] if engine_data.nil?
      engine_data.ResourceDict.FontSet.map(&:Name)
    end

    # Return all font sizes for this layer.
    def sizes
      return [] if engine_data.nil?
      engine_data.EngineDict.StyleRun.RunArray.map do |r|
        r.StyleSheet.StyleSheetData.FontSize
      end.uniq
    end

    # Return all colors used for text in this layer. The colors are returned in RGB
    # format as an array of arrays.
    #
    # => [[255, 0, 0], [0, 0, 255]]
    def colors
      return [] if engine_data.nil?
      engine_data.EngineDict.StyleRun.RunArray.map do |r|
        next unless r.StyleSheet.StyleSheetData.key?('FillColor')
        r.StyleSheet.StyleSheetData.FillColor.Values.map do |v|
          (v * 255).round
        end
      end.uniq
    end

    def engine_data
      @data[:engine_data]
    end

    def parser
      @parser ||= PSD::EngineData.new(@data[:text]['EngineData'])
    end

    def to_hash
      {
        value:      text_value,
        font:       font,
        left:       left,
        top:        top,
        right:      right,
        bottom:     bottom,
        transform:  transform
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