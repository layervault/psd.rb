require 'psd/resources/base'

class PSD
  class Resource
    module Section
      class SavedPath < Base
        def parse
          paths = []
          record_count = @resource.size / 26
          record_count.times do
            paths << PathRecord.new(@file)
          end

          @resource.data = paths
        end
      end
    end
  end
end
