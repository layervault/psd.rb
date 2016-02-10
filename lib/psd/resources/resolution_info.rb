require 'psd/resources/base'

class PSD
  class Resource
    module Section
      class ResolutionInfo < Base
        RES_UNIT_NAMES = %w(pixel/inch pixel/cm).freeze
        UNIT_NAMES = %w(in cm pt picas columns).freeze

        resource_id 1005
        name :resolution_info

        attr_reader :h_res, :h_res_unit, :width_unit
        attr_reader :v_res, :v_res_unit, :height_unit

        def parse
          # 32-bit fixed-point number (16.16)
          @h_res = @file.read_int.to_f / (1 << 16)
          @h_res_unit = @file.read_ushort
          @width_unit = @file.read_ushort

          # 32-bit fixed-point number (16.16)
          @v_res = @file.read_int.to_f / (1 << 16)
          @v_res_unit = @file.read_ushort
          @height_unit = @file.read_ushort

          @resource.data = self
        end

        def h_res_unit_name
          RES_UNIT_NAMES.fetch(h_res_unit - 1, 'unknown')
        end

        def v_res_unit_name
          RES_UNIT_NAMES.fetch(v_res_unit - 1, 'unknown')
        end

        def width_unit_name
          UNIT_NAMES.fetch(width_unit - 1, 'unknown')
        end

        def height_unit_name
          UNIT_NAMES.fetch(height_unit - 1, 'unknown')
        end
      end
    end
  end
end
