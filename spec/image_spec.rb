require 'spec_helper'

describe 'Image Exporting' do
  let(:psd) { PSD.new('spec/files/pixel.psd') }
  let(:blue) { [0, 100, 200, 255] }
  let(:chunky_blue) { ChunkyPNG::Color.rgba(*blue) }

  describe "the full preview image" do
    it "should successfully parse the image data" do
      psd.parse!
      expect(psd).to be_parsed
      expect(psd.image).to_not be_nil
      expect(psd.image.width).to eq(1)
      expect(psd.image.height).to eq(1)
      expect(psd.image.pixel_data).to eq([chunky_blue])
    end

    it "should be able to skip to the image" do
      expect(psd).to_not be_parsed
      expect(psd.image.width).to eq(1)
      expect(psd.image.height).to eq(1)
      expect(psd.image.pixel_data).to eq([chunky_blue])
    end

    describe "as PNG" do
      it "should produce a valid PNG object" do
        expect(psd.image.to_png).to be_an_instance_of(ChunkyPNG::Canvas)

        expect(psd.image.to_png.width).to eq(1)
        expect(psd.image.to_png.height).to eq(1)
        expect(
          ChunkyPNG::Color.to_truecolor_alpha_bytes(psd.image.to_png[0,0])
        ).to eq(blue)
      end
    end
  end

  describe "layer images" do
    before(:each) do
      psd.options[:parse_layer_images] = true
      psd.parse!
    end

    it "should successfully parse the image data" do
      image = psd.tree.children.first.image
      expect(image.width).to eq(1)
      expect(image.height).to eq(1)

      expect(image.pixel_data).to eq([chunky_blue])
    end

    describe "as PNG" do
      it "should produce a valid PNG object" do
        png = psd.tree.children.first.image.to_png
        expect(png).to be_an_instance_of(ChunkyPNG::Canvas)
        expect(png.width).to eq(1)
        expect(png.height).to eq(1)
        expect(
          ChunkyPNG::Color.to_truecolor_alpha_bytes(png[0,0])
        ).to eq(blue)
      end

      it "memorizes the png instance" do
        node = psd.tree.children.first
        png  = node.image.to_png

        expect(png).to be_an_instance_of(ChunkyPNG::Canvas)
        expect(node.image.to_png.__id__).to eq(png.__id__)
      end

      it "memorizes the png_with_mask instance" do
        node = psd.tree.children.first
        png  = node.image.to_png_with_mask

        expect(png).to be_an_instance_of(ChunkyPNG::Canvas)
        expect(node.image.to_png_with_mask.__id__).to eq(png.__id__)
      end
    end
  end

  describe "group images" do
    let(:group_psd) { PSD.new('spec/files/group.psd') }
    let(:group) do
      group_psd.options[:parse_layer_images] = true
      group_psd.parse!

      group_psd.tree.descendant_groups.first
    end

    it "flattens image data of child layers and presents with #to_png" do
      expect(group.width).to eq(1)
      expect(group.height).to eq(1)

      expect(group.to_png).to be_an_instance_of(ChunkyPNG::Canvas)
      expect(group.to_png[0,0]).to eq(chunky_blue)
    end

    it "memorizes the png instance" do
      png = group.to_png

      expect(png).to be_an_instance_of(ChunkyPNG::Canvas)
      expect(group.to_png.__id__).to eq(png.__id__)
    end
  end
end
