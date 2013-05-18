require 'pp'

class PSD
  class PathRecord

    def self.read(file)
      PSD::PathRecord.new(file)
    end

    def initialize(file)
      @file = file

      @record_type = @file.read_short

      case @record_type
      when 0 then read_path_record
      when 3 then read_path_record
      when 1 then read_bezier_point
      when 2 then read_bezier_point
      when 4 then read_bezier_point
      when 5 then read_bezier_point
      when 7 then read_clipboard_record
      when 8 then read_initial_fill
      else @file.seek(24, IO::SEEK_CUR)
      end
    end

    def write(file)
      case @record_type
      when 0 then write_path_record
      when 3 then write_path_record
      when 1 then write_bezier_point
      when 2 then write_bezier_point
      when 4 then write_bezier_point
      when 5 then write_bezier_point
      when 7 then write_clipboard_record
      when 8 then write_initial_fill
      else @file.seek(24, IO::SEEK_CUR)
      end
    end

    def to_hash
      if [1, 2, 4, 5].include? @record_type
        {
          linked: @linked,
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
      else
        {}
      end
    end

    private

    def read_path_record
      @num_points = @file.read_short
      @file.seek(22, IO::SEEK_CUR)
    end

    def write_path_record
      @file.write_short @num_points
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

    def write_bezier_point
      [@preceding_vert, @preceding_horiz, @anchor_vert,
        @anchor_horiz, @leaving_vert, @leaving_horiz].each do |point|
          @file.write_path_number point
      end
    end

    def read_clipboard_record
      @clipboard_top = @file.read_path_number
      @clipboard_left = @file.read_path_number
      @clipboard_bottom = @file.read_path_number
      @clipboard_right = @file.read_path_number
      @clipboard_resolution = @file.read_path_number
      @file.seek(4, IO::SEEK_CUR)
    end

    def write_clipboard_record
      [@clipboard_top, @clipboard_left, @clipboard_bottom,
        @clipboard_right, @clipboard_resolution].each do |point|
          @file.write_path_number point
      end
      @file.seek(4, IO::SEEK_CUR)
    end

    def read_initial_fill
      @initial_fill = @file.read_short
      @file.seek(22, IO::SEEK_CUR)
    end

    def wite_initial_fill
      @file.write_short @initial_fill
      @file.seek(22, IO::SEEK_CUR)
    end
  end
end