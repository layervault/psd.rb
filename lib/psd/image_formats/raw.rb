class PSD::Image
  module Format
    # Parses a RAW uncompressed image
    module RAW
      private

      def parse_raw!(length = @length)
        @length.times do |i|
          @channel_data[i] = @file.read(1).unpack('C')[0]
        end
      end
    end
  end
end