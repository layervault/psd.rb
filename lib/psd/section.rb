class PSD
  class Section
    attr_reader :section_start, :section_end

    def start_section
      @section_start = @file.tell
    end

    def end_section
      @section_end = @file.tell
    end
  end
end