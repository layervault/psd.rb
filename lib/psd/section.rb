class PSD
  module Section
    attr_reader :section_start, :section_end

    def start_section(section=:all)
      @section_start = {} unless @section_start
      @section_start[section] = @file.tell
    end

    def end_section(section=:all)
      @section_end = {} unless @section_end
      @section_end[section] = @file.tell
    end
  end
end