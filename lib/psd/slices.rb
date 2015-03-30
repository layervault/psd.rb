require 'psd/node'

class PSD
  module Slices
    def slices_by_name(name)
      slices.select { |s| s.name == name }
    end
  end
end
