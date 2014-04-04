require 'lib/psd/resources/base'

class PSD
  class Resource
    module Section
      class Base
        def self.resource_id(id = nil)
          @resource_id = id unless id.nil?
          @resource_id
        end

        def self.name(name = nil)
          @name = name unless name.nil?
          @name
        end

        delegate :resource_id, to: :class
        delegate :name, to: :class

        def initialize(file, resource)
          @file = file
          @resource = resource
        end
      end
    end
  end
end