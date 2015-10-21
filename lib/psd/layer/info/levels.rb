require 'psd/layer_info'

class PSD
  class Levels < LayerInfo
    def self.should_parse?(key)
      key == 'levl'
    end

    attr_reader :records

    def parse
      @file.seek 2, IO::SEEK_CUR

      @records = 29.times.map do
        {
          input_floor: @file.read_short,
          input_ceiling: @file.read_short,
          output_floor: @file.read_short,
          output_ceiling: @file.read_short,
          gamma: @file.read_short / 100.0,
        }
      end

      # Photoshop CS (8.0) additional information
      if @file.tell < @section_end - 4
        tag = @file.read_string(4)
        raise 'Extra levels key error' if tag != 'Lvls'

        @file.seek 2, IO::SEEK_CUR

        # Count of total level record structures. Subtract the legacy number of
        # level record structures, 29, to determine how many are remaining in
        # the file for reading.
        extra_levels = @file.read_short - 29

        extra_levels.times do
          @records << {
            input_floor: @file.read_short,
            input_ceiling: @file.read_short,
            output_floor: @file.read_short,
            output_ceiling: @file.read_short,
            gamma: @file.read_short / 100.0
          }
        end
      end
    end
  end
end
