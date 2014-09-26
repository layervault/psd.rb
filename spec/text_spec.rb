require 'spec_helper'

describe 'Text' do
  it "should parse text layer" do
    psd = PSD.new('spec/files/text.psd')
    psd.parse!

    text = psd.tree.children.first.text
    text.should be_an_instance_of(Hash)
    expect(text[:value]).to eq('Test')
  end

  it "can be exported as CSS" do
    psd = PSD.new('spec/files/text.psd')
    psd.parse!

    type = psd.tree.children.first.type
    css = type.to_css
    expect(css).to be_an_instance_of(String)
    expect(css).to include 'MyriadPro-Regular'
    expect(css).to include '37.0pt'
    expect(css).to include 'rgba(24, 24, 24, 255)'
    css.split(/\n/).each do |c|
      expect(c[-1]).to eq(";")
    end
  end
end

describe "Justified Text" do
  let (:psd) { PSD.new('spec/files/alignment_modes.psd').tap(&:parse!) }
  
  ["left", "right", "center", "justify"].each do |alignment|
    it "that is #{alignment} justified can be exported to CSS" do
      type = psd.tree.children_at_path(alignment).first.type
      css = type.to_css
      expect(css).to include "text-align: #{alignment}"
    end
  end
end
