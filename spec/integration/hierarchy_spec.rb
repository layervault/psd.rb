require 'spec_helper'

describe "Hierarchy" do
  it "should parse tree" do
    psd = PSD.new('spec/files/example.psd')
    psd.parse!
    {
      children: [
        {
          name: "Version C",
          height: 900,
          width: 600,
          children:  [
            {
              name: "Make a change and save.",
              height: 31,
              width: 361
            },
            {
              name:  "Logo_Glyph",
              height: 179,
              width: 142
            },
            {
              name: "Matte",
              height: 600,
              width: 900
            }
          ]
        },
        {
          name: "Version B",
          height: 900,
          width: 600,
          children: [
            {
              name: "Make a change and save.",
              height: 31,
              width: 361
            }, {
              name: "Logo_Glyph",
              height: 179,
              width: 142
            },
            {
              name: "Matte",
              height: 600,
              width: 900
            }
          ]
        },
        {
          name: "Version A",
          height: 900,
          width: 600,
          children: [
            {
              name: "Make a change and save.",
              height: 31,
              width: 361
            },
            {
              name: "Logo_Glyph",
              height: 179,
              width: 142
            },
            {
              name: "Matte",
              height: 600,
              width: 900
            }
          ]
        }
      ]
    }.should == psd.tree.to_hash
  end
end