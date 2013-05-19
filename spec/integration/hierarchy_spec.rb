require 'spec_helper'

describe "Hierarchy" do
  it "should parse tree" do
    psd = PSD.new('spec/files/example.psd')
    psd.parse!
    { children: [{:name=>"Version C", :height=>900, :width=>600, :children=>[{:name=>"Make a change and save.", :left=>275, :right=>636, :top=>435, :bottom=>466, :height=>31, :width=>361}, {:name=>"Logo_Glyph", :left=>379, :right=>521, :top=>210, :bottom=>389, :height=>179, :width=>142}, {:name=>"Matte", :left=>0, :right=>900, :top=>0, :bottom=>600, :height=>600, :width=>900}]}, {:name=>"Version B", :height=>900, :width=>600, :children=>[{:name=>"Make a change and save.", :left=>275, :right=>636, :top=>435, :bottom=>466, :height=>31, :width=>361}, {:name=>"Logo_Glyph", :left=>379, :right=>521, :top=>210, :bottom=>389, :height=>179, :width=>142}, {:name=>"Matte", :left=>0, :right=>900, :top=>0, :bottom=>600, :height=>600, :width=>900}]}, {:name=>"Version A", :height=>900, :width=>600, :children=>[{:name=>"Make a change and save.", :left=>275, :right=>636, :top=>435, :bottom=>466, :height=>31, :width=>361}, {:name=>"Logo_Glyph", :left=>379, :right=>521, :top=>210, :bottom=>389, :height=>179, :width=>142}, {:name=>"Matte", :left=>0, :right=>900, :top=>0, :bottom=>600, :height=>600, :width=>900}]}]}.should == psd.tree.to_hash
  end
end