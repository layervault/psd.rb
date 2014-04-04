class PSD
  class Resource
    module Section
      def self.factory(file, resource)
        Section.constants.each do |c|
          next if c == :Base
          
          section = Section.const_get(c)
          next unless section.resource_id == resource.id

          section.new(file, resource).parse
          return section.name
        end

        return nil
      end
    end
  end
end