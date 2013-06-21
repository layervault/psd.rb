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
      read(1).unpack('c*')[0].to_f +
        (read(3).unpack('B*')[0].to_i(2).to_f / (2 ** 24)).to_f # pre-decimal point
    end

    def write_path_number(num)
      write [num.to_i].pack('C')

      # Now for the fun part.
      # We first conver the decimal to be a whole number representing a
      # fraction with the denominator of 2^24
      # Next, we write that number as a 24-bit integer to the file
      binary_numerator = ((num - num.to_i).abs * 2 ** 24).to_i
      write [binary_numerator >> 16].pack('C')
      write [binary_numerator >> 8].pack('C')
      write [binary_numerator >> 0].pack('C')
    end

    def read_unicode_string(length=nil)
      length ||= read_int if length.nil?
      !length.nil? && length > 0 ? read(length * 2).encode('UTF-8', 'MacRoman').delete("\000") : ''
    end
  end
end