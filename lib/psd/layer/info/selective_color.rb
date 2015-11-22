require 'psd/layer_info'

class PSD
  class SelectiveColor < LayerInfo
    def self.should_parse?(key)
      key == 'selc'
    end

    attr_reader :correction_mode, :cyan_correction, :magenta_correction,
                :yellow_correction, :black_correction

    def parse
      @file.seek 2, IO::SEEK_CUR

      @correction_mode = @file.read_short == 0 ? :relative : :absolute
      @cyan_correction = []
      @magenta_correction = []
      @yellow_correction = []
      @black_correction = []

      10.times do |i|
        # First record is all 0 and is ignored by Photoshop
        @file.seek(8, IO::SEEK_CUR) and next if i == 0

        @cyan_correction    << @file.read_short
        @magenta_correction << @file.read_short
        @yellow_correction  << @file.read_short
        @black_correction   << @file.read_short
      end
    end
  end
end
