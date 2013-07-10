require 'spec_helper'

describe 'Parsing' do
  before(:each) do
    @psd = PSD.new('spec/files/example.psd')
  end

  it "should parse without error" do
    @psd.parse!
    @psd.parsed?.should be_true
  end

  describe 'Header' do
    before(:each) do
      @psd.parse!
    end

    it "should contain data" do
      @psd.header.should_not be_nil
    end

    it "should be the proper version" do
      @psd.header.version.should == 1
    end

    it "should have the proper number of channels" do
      @psd.header.channels.should == 3
    end

    it "should parse the proper document dimensions" do
      @psd.header.width.should == 900
      @psd.header.height.should == 600
    end

    it "should correctly parse the color mode" do
      @psd.header.mode.should == 3
      @psd.header.mode_name.should == 'RGBColor'
    end
  end
end