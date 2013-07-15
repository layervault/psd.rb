require "bindata"
require "psd/enginedata"

dir_root = File.dirname(File.absolute_path(__FILE__))

require dir_root + '/psd/section'
require dir_root + '/psd/skip_block'
require dir_root + '/psd/image_formats/raw'
require dir_root + '/psd/image_formats/rle'
require dir_root + '/psd/image_modes/rgb'
require dir_root + '/psd/image_exports/png'
require dir_root + '/psd/has_children'
require dir_root + '/psd/nodes/ancestry'
require dir_root + '/psd/nodes/search'
require dir_root + '/psd/node'
require dir_root + '/psd/nodes/parse_layers'
require dir_root + '/psd/nodes/lock_to_origin'
require dir_root + '/psd/layer_adjustment'
require dir_root + '/psd/layer_info/type/typetool'

Dir.glob(dir_root + '/psd/layer_info/**/*') { |file| require file if File.file?(file) }
Dir.glob(dir_root + '/psd/**/*') { |file| require file if File.file?(file) }

class PSD
  include Helpers
  include NodeExporting

  def initialize(file)
    @file = PSD::File.new(file, 'rb')
    @file.seek 0 # just IN FUCKING CASE

    @header = nil
    @resources = nil
    @layer_mask = nil
    @parsed = false
  end

  # There is a specific order that must be followed when parsing
  # the PSD. Sections can be skipped if needed. This method will
  # parse all sections of the PSD.
  def parse!
    header
    resources
    layer_mask
    image

    @parsed = true

    return true
  end

  def parsed?
    @parsed
  end

  def header
    @header ||= Header.read(@file)
  end

  def resources
    return @resources.data unless @resources.nil?

    @resources = Resources.new(@file)
    @resources.parse

    return @resources.data
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

  def export(file)
    parse! unless parsed?

    # Create our file for writing
    outfile = File.open(file, 'w')

    # Reset the file pointer
    @file.seek 0
    @header.write outfile
    @file.seek @header.num_bytes, IO::SEEK_CUR

    # Nothing in the header or resources we want to bother with changing
    # right now. Write it straight to file.
    outfile.write @file.read(@resources.end_of_section - @file.tell)

    # Now, the changeable part. Layers and masks.
    layer_mask.export(outfile)

    # And the rest of the file (merged image data)
    outfile.write @file.read
    outfile.flush
  end
end