require 'psd/resources/base'

class PSD
  class Resource
    module Section
      class XMPMetadata < Base
        resource_id 1060
        name :xmp_metadata

        attr_reader :xml, :data
        alias_method :to_hash, :data

        def parse
          @xml = @file.read(@resource.size)
          @data = {}

          @xmp = XMP.new(xml)
          @xmp.namespaces.each do |a|
            parse_tree(a.to_sym)
          end
        rescue Java::OrgW3cDom::DOMException
          PSD.logger.error "Unable to parse XMP Metadata"
        ensure
          @resource.data = self
        end

        private

        def parse_tree(attr_name)
          @data[attr_name] = {}
          @xmp.send(attr_name).attributes.each do |a|
            begin
              @data[attr_name][a.to_sym] = @xmp.send(attr_name).send(a)[0]
            rescue
              @data[attr_name][a.to_sym] = parse_text_node(@xmp.send(attr_name), "//#{attr_name}:#{a}")
            end
          end
        end

        def parse_text_node(node, path)
          node.send(:xml).xpath(path).first.text
        end
      end
    end
  end
end