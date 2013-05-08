# This doesn't seem to be working properly yet.
# Creates an infinite loop for some reason.

class PSD
  class SkipBlock < BinData::Primitive
    endian  :big

    uint32  :len
    string  :skipped_data, read_length: :len

    def get; self.data; end
    def set(v); end
  end
end