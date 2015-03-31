require 'psd/node'

class PSD
  module Slices
    def slices_by_name(name)
      slices.select { |s| s.name == name }
    end

    def slice_by_id(id)
      slices.select { |s| s.id == id }.first
    end
  end
end
