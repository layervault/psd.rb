require 'psd/layer/blend_modes'
require 'psd/layer/blending_ranges'
require 'psd/layer/channel_image'
require 'psd/layer/exporting'
require 'psd/layer/helpers'
require 'psd/layer/info'
require 'psd/layer/mask'
require 'psd/layer/name'
require 'psd/layer/path_components'
require 'psd/layer/position_and_channels'

class PSD
  # Represents a single layer and all of the data associated with
  # that layer.
  class Layer
    include BlendModes
    include BlendingRanges
    include ChannelImage
    include Exporting
    include Info
    include Mask
    include Name
    include PathComponents
    include PositionAndChannels
    include Helpers

    attr_reader :id, :info_keys, :header
    attr_accessor :group_layer, :node, :file

    # Initializes all of the defaults for the layer.
    def initialize(file, header)
      @file = file
      @header = header

      @mask = {}
      @blending_ranges = {}
      @adjustments = {}
      @channels_info = []
      @blend_mode = {}
      @group_layer = nil

      # Just used for tracking which layer adjustments we're parsing.
      # Not essential.
      @info_keys = []
    end

    # Parse the layer and all of it's sub-sections.
    def parse(index=nil)
      @id = index

      parse_position_and_channels
      parse_blend_modes

      extra_len = @file.read_int
      @layer_end = @file.tell + extra_len

      parse_mask_data
      parse_blending_ranges
      parse_legacy_layer_name
      parse_layer_info

      PSD.logger.debug "Layer name = #{name}"

      @file.seek @layer_end # Skip over any filler zeros

      return self
    end

    # We just delegate this to a normal method call.
    def [](val)
      self.send(val)
    end
  end
end
