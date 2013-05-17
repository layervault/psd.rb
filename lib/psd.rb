require "bindata"

dir_root = File.dirname(File.absolute_path(__FILE__))

require dir_root + '/psd/skip_block'
Dir.glob(dir_root + '/psd/*') {|file| require file}

class PSD
  include PSD::Helpers

  def initialize(file)
    @file = file.is_a?(String) ? PSD::File.open(file) : file

    @header = nil
    @resources = nil
    @layer_mask = nil
  end

  # There is a specific order that must be followed when parsing
  # the PSD. Sections can be skipped if needed. This method will
  # parse all sections of the PSD.
  def parse!
    header
    resources
    layer_mask

    @layers = @layer_mask.layers

    return true
  end

  def header
    @header ||= PSD::Header.read(@file)
  end

  def resources
    @resources ||= PSD::Resources.new(@file).parse
  end

  def layer_mask
    header
    resources

    @layer_mask ||= PSD::LayerMask.new(@file, @header).parse
  end
end