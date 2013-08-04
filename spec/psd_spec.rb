require 'spec_helper'

describe 'PSD' do
  let(:filename) { 'spec/files/example.psd' }

	it 'should open a file without a block' do
    psd = PSD.open(filename)
    psd.parsed?.should == true
    psd.should be_instance_of PSD
	end

  it 'should refuse to open a bad filename' do
    expect { PSD.open('') }.to raise_error
  end

  it 'should open a file and feed it to a block' do
    PSD.open(filename) do |psd|
      psd.parsed?.should == true
      psd.should be_instance_of PSD
    end
  end

  it 'should open a file and feed it to a block DSL style' do
    PSD.open(filename) do
      parsed?.should == true
      is_a?(PSD).should == true
    end
  end
end