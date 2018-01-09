class PSD
  # Parses a vector path
  class PathRecord
    attr_accessor :layer

    # Facade to make it easier to parse the path record.
    def self.read(layer)
      pr = PSD::PathRecord.new(layer.file)
      pr.layer = layer
      pr
    end

    # Reads the record type and begins parsing accordingly.
    def initialize(file)
      @file = file

      @record_type = @file.read_short

      case @record_type
      when 0, 3 then read_path_record
      when 1, 2, 4, 5 then read_bezier_point
      when 6 then read_path_fill_rule_record
      when 7 then read_clipboard_record
      when 8 then read_initial_fill
      else @file.seek(24, IO::SEEK_CUR)
      end
    end

    # Exports the path record to an easier to work with hash.
    def to_hash
      case @record_type
      when 0, 3
        {
          num_points: @num_points
        }
      when 1, 2, 4, 5
        {
          linked: @linked,
          closed: [1, 2].include?(@record_type),
          preceding: {
            vert: @preceding_vert,
            horiz: @preceding_horiz
          },
          anchor: {
            vert: @anchor_vert,
            horiz: @anchor_horiz
          },
          leaving: {
            vert: @leaving_vert,
            horiz: @leaving_horiz
          }
        }
      when 7
        {
          clipboard: {
            top: @clipboard_top,
            left: @clipboard_left,
            bottom: @clipboard_bottom,
            right: @clipboard_right,
            resolution: @clipboard_resolution
          }
        }
      when 8
        {
          initial_fill: @initial_fill
        }
      else
        {}
      end.merge({ record_type: @record_type })
    end

    # Is this record a bezier point?
    def is_bezier_point?
      [1,2,4,5].include? @record_type
    end

    private

    def read_path_record
      @num_points = @file.read_short
      @file.seek(22, IO::SEEK_CUR)
    end

    def read_bezier_point
      @linked = [1,4].include? @record_type

      @preceding_vert = @file.read_path_number
      @preceding_horiz = @file.read_path_number

      @anchor_vert = @file.read_path_number
      @anchor_horiz = @file.read_path_number

      @leaving_vert = @file.read_path_number
      @leaving_horiz = @file.read_path_number
    end

    def read_path_fill_rule_record
      @file.seek(24, IO::SEEK_CUR)
    end

    def read_clipboard_record
      @clipboard_top = @file.read_path_number
      @clipboard_left = @file.read_path_number
      @clipboard_bottom = @file.read_path_number
      @clipboard_right = @file.read_path_number
      @clipboard_resolution = @file.read_path_number
      @file.seek(4, IO::SEEK_CUR)
    end

    def read_initial_fill
      @initial_fill = @file.read_short
      @file.seek(22, IO::SEEK_CUR)
    end
  end
end
