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

    def start_of_section(section=:all)
      @section_start[section]
    end

    def end_of_section(section=:all)
      @section_end[section]
    end
  end
end