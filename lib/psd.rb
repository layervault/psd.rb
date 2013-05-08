require "bindata"

dir_root = File.dirname(File.absolute_path(__FILE__))

require dir_root + '/psd/skip_block'
Dir.glob(dir_root + '/psd/*') {|file| require file}

module PSD
  class File
    include PSD::Helpers

    def initialize(file)
      @file = file.is_a?(String) ? ::File.open(file) : file

      @header = nil
    end

    # There is a specific order that must be followed when parsing
    # the PSD. Sections can be skipped if needed. This method will
    # parse all sections of the PSD.
    def parse!
      header
      resources

      return true
    end

    def header
      @header ||= PSD::Header.read(@file)
    end

    def resources
      @resources ||= PSD::Resources.new(@file).parse
    end
  end
end