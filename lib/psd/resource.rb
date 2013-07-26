class PSD
  # Definition for a single Resource record.
  #
  # Most of the resources are options/preferences set by the user
  # or automatically by Photoshop.
  class Resource < BinData::Record
    endian  :big

    string  :type, read_length: 4
    uint16  :id
    uint8   :name_len
    stringz :name, read_length: :name_length
    uint32  :res_size

    skip    length: :resource_size

    #---
    # Really weird padding business
    def name_length
      Util.pad2(name_len + 1) - 1
    end

    def resource_size
      Util.pad2(res_size)
    end
  end
end