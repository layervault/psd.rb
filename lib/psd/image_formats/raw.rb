class PSD
  module ImageFormat
    # Parses a RAW uncompressed image
    module RAW
      private

      def parse_raw!
        @channel_data = @file.read(@length).bytes
      end
    end
  end
end
