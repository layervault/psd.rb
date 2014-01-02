class PSD
  class MaskService
    attr_accessor :pixel_data, :mask_data, :layer_width, :layer_height

    def initialize(layer, options = {})
      @layer = layer
      @options = options

      @pixel_data = @layer.image.pixel_data
      @mask_data = @layer.image.mask_data

      @layer_width = (@layer.folder? ? @layer.mask.width : @layer.width).to_i
      @layer_height = (@layer.folder? ? @layer.mask.height : @layer.height).to_i
    end

    def apply
      PSD.logger.debug "Beginning PNG export with mask"
      
      # We generate the preview at the document size instead to make applying the mask
      # significantly easier.
      width = @layer.header.width.to_i
      height = @layer.header.height.to_i
      png = ChunkyPNG::Canvas.new(width, height, ChunkyPNG::Color::TRANSPARENT)

      i = 0
      @layer_height.times do |y|
        @layer_width.times do |x|
          offset_x = x + @layer.left
          offset_y = y + @layer.top

          i +=1 and next if offset_x < 0 || offset_y < 0 || offset_x >= png.width || offset_y >= png.height

          png[offset_x, offset_y] = @pixel_data[i]
          i += 1
        end
      end
      
      # Now we apply the mask
      i = 0
      @layer.mask.height.times do |y|
        @layer.mask.width.times do |x|
          offset_x = @layer.mask.left + x
          offset_y = @layer.mask.top + y

          i += 1 and next if offset_x < 0 || offset_y < 0 || offset_x >= png.width || offset_y >= png.height

          color = ChunkyPNG::Color.to_truecolor_alpha_bytes(png[offset_x, offset_y])
          color[3] = color[3] * @mask_data[i] / 255

          png[offset_x, offset_y] = ChunkyPNG::Color.rgba(*color)
          i += 1
        end
      end

      crop_left = PSD::Util.clamp(@layer.left, 0, png.width)
      crop_top = PSD::Util.clamp(@layer.top, 0, png.height)
      crop_width = PSD::Util.clamp(@layer_width, 0, png.width - crop_left)
      crop_height = PSD::Util.clamp(@layer_height, 0, png.height - crop_top)

      png.crop!(crop_left, crop_top, crop_width, crop_height)
      PSD::LayerStyles.new(@layer, transparent_base, png).apply! if @options[:layer_styles]

      return png
    end

    private

    def transparent_base
      ChunkyPNG::Canvas.new(width.to_i, height.to_i, ChunkyPNG::Color::TRANSPARENT)
    end
  end
end