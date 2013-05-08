require "bindata"

dir_root = File.dirname(File.absolute_path(__FILE__))

require dir_root + '/psd/skip_block'
Dir.glob(dir_root + '/psd/*') {|file| require file}

module PSD
  class File
    def initialize(file)
      @file = file.is_a?(String) ? ::File.open(file) : file

      @header = nil
    end

    # There is a specific order that must be followed when parsing
    # the PSD. Sections can be skipped if needed. This method will
    # parse all sections of the PSD.
    def parse!
      header

      return true
    end

    def header
      @header ||= PSD::Header.read(@file)
    end

    def width
      header.cols
    end

    def height
      header.rows
    end
  end
end