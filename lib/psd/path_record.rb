class PSD
  class PathRecord
    attr_accessor :layer

    def self.read(layer)
      pr = PSD::PathRecord.new(layer.file)
      pr.layer = layer
      pr
    end

    def initialize(file)
      @file = file

      @record_type = @file.read_short

      puts "reading record type #{@record_type} at #{@file.tell}"
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
      puts "writing record type #{@record_type} at #{file.tell}"
      file.write_short @record_type
      case @record_type
      when 0 then write_path_record(file)
      when 3 then write_path_record(file)
      when 1 then write_bezier_point(file)
      when 2 then write_bezier_point(file)
      when 4 then write_bezier_point(file)
      when 5 then write_bezier_point(file)
      when 7 then write_clipboard_record(file)
      when 8 then write_initial_fill(file)
      else file.seek(24, IO::SEEK_CUR)
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

    def translate(x=0, y=0)
      return unless is_bezier_point?

      document_width, document_height = @layer.document_dimensions
      translate_x_ratio = x.to_f / document_width.to_f
      translate_y_ratio = y.to_f / document_height.to_f

      @preceding_vert += translate_y_ratio
      @preceding_horiz += translate_x_ratio
      @anchor_vert += translate_y_ratio
      @anchor_horiz += translate_x_ratio
      @leaving_vert += translate_y_ratio
      @leaving_horiz += translate_x_ratio
    end

    def is_bezier_point?
      [1,2,4,5].include? @record_type
    end

    private

    def read_path_record
      @num_points = @file.read_short
      @file.seek(22, IO::SEEK_CUR)
    end

    def write_path_record(file)
      file.write_short @num_points
      file.seek(22, IO::SEEK_CUR)
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

    def write_bezier_point(file)
      [@preceding_vert, @preceding_horiz, @anchor_vert,
        @anchor_horiz, @leaving_vert, @leaving_horiz].each do |point|
          puts "writing #{point} to #{file.pos}"
          file.write_path_number point
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

    def write_clipboard_record(file)
      [@clipboard_top, @clipboard_left, @clipboard_bottom,
        @clipboard_right, @clipboard_resolution].each do |point|
          file.write_path_number point
      end
      file.seek(4, IO::SEEK_CUR)
    end

    def read_initial_fill
      @initial_fill = @file.read_short
      @file.seek(22, IO::SEEK_CUR)
    end

    def write_initial_fill(file)
      file.write_short @initial_fill
      file.seek(22, IO::SEEK_CUR)
    end
  end
end