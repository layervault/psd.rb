class PSD
  class File < ::File
    FORMATS = {
      double: {
        length: 8,
        code: 'G'
      },
      float: {
        length: 4,
        code: 'F'
      },
      uint: {
        length: 4,
        code: 'L>'
      },
      int: {
        length: 4,
        code: 'l>'
      },
      ushort: {
        length: 2,
        code: 'S>'
      },
      short: {
        length: 2,
        code: 's>'
      }
    }

    FORMATS.each do |format, info|
      define_method "read_#{format}" do
        read(info[:length]).unpack(info[:code])[0]
      end

      define_method "write_#{format}" do |val|
        write [val].pack(info[:code])
      end
    end

    # Adobe's lovely signed 32-bit fixed-point number with 8bits.24bits
    #   http://www.adobe.com/devnet-apps/photoshop/fileformatashtml/PhotoshopFileFormats.htm#50577409_17587
    def read_path_number
      read(1).unpack('c*')[0] + # pre-decimal point
        (read(3).unpack('B*')[0].to_i(2) / (2 ** 24)) # post-decimal point
    end

    def write_path_number(num)
      write BinData::Int8.new num.to_i

      # Now for the fun part.
      # We first conver the decimal to be a whole number representing a
      # fraction with the denominator of 2^24
      # Next, we write that number as a 24-bit integer to the file
      numerator = ((num - num.to_i) * 2 ** 24).to_i
      write numerator.to_s(2).scan(/\d{8}/).map(&:to_i).pack('C*')
    end
  end
end