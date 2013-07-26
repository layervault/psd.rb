# Helper class that parses a pascal string, which is a
# string that has it's length prepended to it.
class PascalString < BinData::Record
  uint8  :len,  value: lambda { data.length }
  string :data, read_length: :len

  def get
    self.data
  end

  def set(v)
    self.data = v
  end
end