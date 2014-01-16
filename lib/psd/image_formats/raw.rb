class PSD
  module ImageFormat
    # Parses a RAW uncompressed image
    module RAW
      private

      def parse_raw!(length = @length)
        @channel_data = @file.read(length).bytes.to_a
      end
    end
  end
end