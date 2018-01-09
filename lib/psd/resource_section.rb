class PSD
  class Resource
    module Section
      def self.factory(file, resource)
        if path_resource?(resource)
          section = Section::SavedPath.new(file, resource)
          section.parse
          return section.name
        end

        Section.constants.each do |c|
          next if c == :Base

          section = Section.const_get(c)
          next unless section.resource_id == resource.id

          section.new(file, resource).parse
          return section.name
        end

        return nil
      end

      def self.path_resource?(resource)
        resource.id >= 2000 && resource.id <= 2997
      end
    end
  end
end
