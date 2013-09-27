class PSD
  module ImageFormat
    # Parses a RAW uncompressed image
    module RAW
      private

      def parse_raw!(length = @length)
        @length.times do |i|
          @channel_data[i] = @file.read(1).bytes.to_a[0]
        end
      end
    end
  end
end