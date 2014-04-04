class PSD
  class Resource
    class Section
      def self.factory(file, resource)
        Section.constants.each do |c|
          section = Section.const_get(c)
          next unless section.resource_id == resource.id

          section.new(file, resource).parse
          return section.name
        end

        return nil
      end

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