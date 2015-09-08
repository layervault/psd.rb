require 'spec_helper'

describe 'Photoshop Big parsing' do
  before(:each) do
    @psd = PSD.new('spec/files/example.psb')
  end

  it 'parses without error' do
    @psd.parse!
    expect(@psd).to be_parsed
  end

  describe 'Header' do
    before(:each) do
      @psd.parse!
    end

    it 'should contain data' do
      expect(@psd.header).not_to be_nil
    end

    it 'should be the proper version' do
      expect(@psd.header.version).to eq(2)
    end
  end

  describe 'Layer Mask' do
    before(:each) do
      @psd.parse!
    end

    it 'contains data' do
      expect(@psd.layer_mask).to_not be_nil
      expect(@psd.layer_mask).to be_an_instance_of(PSD::LayerMask)
    end

    it 'contains layers' do
      expect(@psd.layer_mask.layers.size).to be > 0
    end
  end

  describe 'Layers' do
    before(:each) do
      @psd.parse!
    end

    it 'contains each layer' do
      expect(@psd.layer_mask.layers.size).to eq(2)
      expect(@psd.layers).to be @psd.layer_mask.layers
      @psd.layers.each { |l| expect(l).to be_an_instance_of(PSD::Layer) }
    end

    it 'shows the proper layer names' do
      expect(@psd.layers.map(&:name)).to match_array(['summer', 'haze'])
    end
  end
end
