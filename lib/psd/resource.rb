module PSD
  class Resource < BinData::Record
    endian  :big

    string  :type, read_length: 4
    uint16  :id
    uint8   :name_len
    stringz :name, read_length: :name_length
    uint32  :res_size

    skip    length: :resource_size

    # Really weird padding business
    def name_length
      pad2(name_len + 1) - 1
    end

    def resource_size
      pad2(res_size)
    end

    def pad2(i)
      ((i + 1) / 2) * 2
    end
  end
end