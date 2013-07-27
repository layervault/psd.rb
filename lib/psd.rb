require "bindata"
require "psd/enginedata"

require_relative 'psd/section'

dir_root = File.dirname(File.absolute_path(__FILE__)) + '/psd'
[
  '/image_formats/*',
  '/image_modes/*',
  '/image_exports/*',
  '/nodes/*',
  '/layer_info/**/*',
  '/**/*'
].each do |path|
  Dir.glob(dir_root + path) { |file| require file if File.file?(file) }
end

# A general purpose parser for Photoshop files. PSDs are broken up in to 4 logical sections:
# the header, resources, the layer mask (including layers), and the preview image. We parse
# each of these sections in order.
class PSD
  include Helpers
  include NodeExporting

  # Just used to track what layer info keys we didn't parse in this file for development purposes.
  def self.keys; @@keys; end
  @@keys = []

  DEFAULTS = {
    parse_image: false,
    parse_layer_images: false
  }

  attr_reader :file

  # Create and store a reference to our PSD file
  def initialize(file, opts={})
    @file = PSD::File.new(file, 'rb')
    @file.seek 0 # If the file was previously used and not closed

    @opts = DEFAULTS.merge(opts)
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
    image if @opts[:parse_image]
    
    @parsed = true

    return true
  end

  # Has our PSD been parsed yet?
  def parsed?
    @parsed
  end

  # Get the Header, parsing it if needed.
  def header
    @header ||= Header.read(@file)
  end

  # Get the Resources section, parsing if needed.
  def resources
    return @resources.data unless @resources.nil?

    ensure_header

    @resources = Resources.new(@file)
    @resources.parse

    return @resources.data
  end

  # Get the LayerMask section. Ensures the header and resources
  # have been parsed first since they are required.
  def layer_mask
    ensure_header
    ensure_resources

    @layer_mask ||= LayerMask.new(@file, @header).parse
  end

  # Get the full size flattened preview Image.
  def image
    ensure_header
    ensure_resources
    ensure_layer_mask

    @image ||= Image.new(@file, @header).parse
  end

  # Export the current file to a new PSD. This may or may not work.
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

  private

  def ensure_header
    header # Header is always required
  end

  def ensure_resources
    return unless @resources.nil?
    
    @resources = Resources.new(@file)
    @resources.skip
  end

  def ensure_layer_mask
    return unless @layer_mask.nil?

    @layer_mask = LayerMask.new(@file, @header)
    @layer_mask.skip
  end
end