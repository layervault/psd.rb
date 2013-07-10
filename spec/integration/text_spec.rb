require 'spec_helper'

describe 'Text' do
  it "should parse text layer" do
    psd = PSD.new('spec/files/text.psd')
    psd.parse!

    text = psd.tree.children.first.text
    text.should be_an_instance_of(Hash)
    text[:value].should == 'Test'
  end
end