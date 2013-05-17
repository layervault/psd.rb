class PSD
  module Helpers
    def width
      header.cols
    end

    def height
      header.rows
    end

    def layers
      layer_mask.layers
    end

    def actual_layers
      layers.delete_if { |l| l.folder? || l.hidden? }
    end

    def folders
      layers.select { |l| l.folder? }
    end
  end
end