class PSD
  class Image
    include Format::RAW
    include Format::RLE
    include Mode::RGB

    COMPRESSIONS = [
      'Raw',
      'RLE',
      'ZIP',
      'ZIPPrediction'
    ]

    CHANNEL_INFO = [
      {id: 0},
      {id: 1},
      {id: 2},
      {id: -1}
    ]

    def initialize(file, header)
      @file = file
      @header = header

      @num_pixels = width * height
      @num_pixels *= 2 if depth == 16

      calculate_length
      @channel_data = NArray.int(@length)

      @start_pos = @file.tell
      @end_pos = @start_pos + @length

      @pixel_data = []
    end

    def parse
      @compression = parse_compression!

      # ZIP not implemented
      if [2, 3].include?(@compression)
        @file.seek @end_pos and return
      end

      parse_image_data!
    end

    [:height, :width, :channels, :depth, :mode].each do |attribute|
      define_method attribute do
        @header.send(attribute)
      end
    end

    private

    def calculate_length
      @length = case depth
      when 1 then (width + 7) / 8 * height
      when 16 then width * height * 2
      else width * height
      end

      @channel_length = @length
      @length *= channels
    end

    def parse_compression!
      @file.read_short
    end

    def parse_image_data!
      case @compression
      when 0 then parse_raw!
      when 1 then parse_rle!
      when 2, 3 then parse_zip!
      else @file.seek(@end_pos)
      end

      process_image_data
    end

    def process_image_data
      case mode
      when 3
        combine_rgb8_channel if depth == 8
        combine_rgb16_channel if depth == 16
      end
    end
  end
end