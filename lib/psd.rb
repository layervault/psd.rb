require "bindata"
require "psd/enginedata"

require_relative 'psd/section'
require_relative 'psd/skip_block'
require_relative 'psd/image_formats/raw'
require_relative 'psd/image_formats/rle'
require_relative 'psd/image_modes/rgb'
require_relative 'psd/image_exports/png'
require_relative 'psd/has_children'
require_relative 'psd/nodes/ancestry'
require_relative 'psd/nodes/search'
require_relative 'psd/node'
require_relative 'psd/nodes/parse_layers'
require_relative 'psd/nodes/lock_to_origin'
require_relative 'psd/layer_info'
require_relative 'psd/layer_info/typetool'

dir_root = File.dirname(File.absolute_path(__FILE__))
Dir.glob(dir_root + '/psd/layer_info/**/*') { |file| require file if File.file?(file) }
Dir.glob(dir_root + '/psd/**/*') { |file| require file if File.file?(file) }

class PSD
  include Helpers
  include NodeExporting

  @@keys = []

  def self.keys; @@keys; end

  attr_reader :file

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