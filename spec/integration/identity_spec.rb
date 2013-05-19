require 'spec_helper'
require 'tempfile'

describe "Identity exports" do
  it "should export the simplest PSD" do
    filepath = 'spec/files/simplest.psd'
    psd = PSD.new(filepath)
    psd.parse!
    tmpfile = Tempfile.new("simplest_export.psd")
    psd.export tmpfile.path

    Digest::MD5.hexdigest(tmpfile.read).should == Digest::MD5.hexdigest(File.read(filepath))
  end

  it "should export a file with a layer" do
    filepath = 'spec/files/one_layer.psd'
    psd = PSD.new(filepath)
    psd.parse!
    tmpfile = Tempfile.new("one_layer_export.psd")
    psd.export tmpfile.path

    Digest::MD5.hexdigest(tmpfile.read).should == Digest::MD5.hexdigest(File.read(filepath))
  end

  it "should export a PSD with vector paths" do
    filepath = 'spec/files/path.psd'
    psd = PSD.new(filepath)
    psd.parse!
    tmpfile = Tempfile.new("path_export.psd")
    psd.export tmpfile.path

    Digest::MD5.hexdigest(tmpfile.read).should == Digest::MD5.hexdigest(File.read(filepath))
  end
end
