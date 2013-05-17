require "bindata"
require "narray"

dir_root = File.dirname(File.absolute_path(__FILE__))

require dir_root + '/psd/skip_block'
require dir_root + '/psd/image_formats/raw'
require dir_root + '/psd/image_formats/rle'
require dir_root + '/psd/image_modes/rgb'
require dir_root + '/psd/image_exports/png'
require dir_root + '/psd/has_children.rb'
require dir_root + '/psd/node'
Dir.glob(dir_root + '/psd/**/*') { |file| require file if File.file?(file) }

class PSD
  include Helpers

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
    image

    return true
  end

  def header
    @header ||= Header.read(@file)
  end

  def resources
    @resources ||= Resources.new(@file).parse
  end

  def layer_mask
    header
    resources

    @layer_mask ||= LayerMask.new(@file, @header).parse
  end

  def image
    layer_mask

    @image ||= Image.new(@file, @header).parse
  end
end