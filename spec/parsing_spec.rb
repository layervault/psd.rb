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

  describe 'Resources' do
    before(:each) do
      @psd.parse!
    end

    it "should contain data" do
      @psd.resources.should_not be_nil
      @psd.resources.is_a?(Array).should be_true
      @psd.resources.size.should >= 1
    end

    it "should be of type 8BIM" do
      @psd.resources.each { |r| r.type.should == '8BIM' }
    end

    it "should have an ID" do
      @psd.resources.each do |r|
        r.id.should_not be_nil
      end
    end
  end

  describe 'Layer Mask' do
    before(:each) do
      @psd.parse!
    end

    it "should contain data" do
      @psd.layer_mask.should_not be_nil
      @psd.layer_mask.is_a?(PSD::LayerMask).should be_true
    end

    it "should contain layers" do
      @psd.layer_mask.layers.size.should > 0
    end

    it "should contain the global layer mask data" do
      pending "Not implemented yet"

      @psd.layer_mask.global_mask.should_not be_nil
    end
  end

  describe 'Layers' do
    before(:each) do
      @psd.parse!
    end

    it "should contain each layer" do
      @psd.layer_mask.layers.size.should == 15
      @psd.layers.should == @psd.layer_mask.layers
      @psd.layers.each { |l| l.is_a?(PSD::Layer).should be_true }
    end

    it "should have a name" do
      @psd.layers.first.name.should == 'Version C'
    end

    it "should properly identify folders" do
      @psd.layers.first.folder?.should be_true
      @psd.layers.select { |l| l.name == 'Matte' }.first.folder?.should be_false
    end

    it "should properly detect visibility" do
      @psd.layers.first.visible?.should be_false
      @psd
        .layers
        .select { |l| l.name == 'Version A' }.first
        .visible?
        .should be_true
    end

    it "should properly calculate dimensions" do
      layer = @psd.layers.select { |l| l.name == 'Logo_Glyph' }.last
      layer.width.should == 142
      layer.height.should == 179
    end

    it "should properly calculate coordinates" do
      layer = @psd.layers.select { |l| l.name == 'Logo_Glyph' }.last
      layer.left.should == 379
      layer.top.should == 210
    end

    it "should have a blend mode" do
      layer = @psd.layers.select { |l| l.name == 'Version A' }.last
      layer.blend_mode.should_not be_nil
      layer.blend_mode.mode.should == 'normal'
      layer.blend_mode.opacity.should == 255
      layer.blend_mode.opacity_percentage.should == 100
      layer.blend_mode.visible.should be_true
    end
  end
end