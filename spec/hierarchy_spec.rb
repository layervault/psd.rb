require 'spec_helper'

describe "Hierarchy" do
  before(:each) do
    @psd = PSD.new('spec/files/example.psd')
  end

  it "should parse tree" do
    @psd.parse!
    
    tree = @psd.tree.to_hash
    expect(tree).to include :children
    expect(tree[:children].length).to eq(3)
  end

  describe "Ancestry" do
    before(:each) do
      @psd.parse!
      @tree = @psd.tree
    end

    it "should provide tree traversal methods" do
      expect(@tree).to respond_to(:root)
      expect(@tree).to respond_to(:siblings)
      expect(@tree).to respond_to(:descendants)
      expect(@tree).to respond_to(:subtree)
    end

    it "should properly identify the root node" do
      expect(@tree.root?).to be_true
      expect(@tree.root).to be @tree
      expect(@tree.children.last.root).to be @tree
    end

    it "should retrieve all descendants of a node" do
      expect(@tree.descendants.size).to eq(12)
      expect(@tree.descendant_layers.size).to eq(9)
      expect(@tree.descendant_groups.size).to eq(3)
      expect(@tree.descendants.first).not_to be @tree
    end

    it "should retreive the entire subtree of a node" do
      expect(@tree.subtree.size).to eq(13)
      expect(@tree.subtree_layers.size).to eq(9)
      expect(@tree.subtree_groups.size).to eq(3)
      expect(@tree.subtree.first).to be @tree
    end

    it "should properly identify the existence of children" do
      expect(@tree).to have_children
      expect(@tree).to_not be_childless
      expect(@tree.descendant_layers.first).to_not have_children
      expect(@tree.descendant_layers.first).to be_childless
    end

    it "should retrieve all siblings of a node" do
      expect(@tree.children.first.siblings).to be @tree.children
      expect(@tree.children.first.siblings).to include @tree.children.first
      expect(@tree.children.first).to have_siblings
      expect(@tree.children.first).to_not be_only_child
    end

    it "should properly calculate node depth" do
      expect(@tree.depth).to eq(0)
      expect(@tree.descendant_layers.last.depth).to eq(2)
      expect(@tree.children.first.depth).to eq(1)
    end

    it "should be able to generate a path to a node" do
      node = @tree.children_at_path('Version A/Matte').first
      expect(node.path).to eq('Version A/Matte')
    end

    describe "Searching" do
      it "should find a node given a path" do
        expect(@tree.children_at_path('Version A/Matte')).to be_an_instance_of(Array)
        expect(@tree.children_at_path('Version A/Matte').size).to eq(1)
        expect(@tree.children_at_path('Version A/Matte').first).to be_an_instance_of(PSD::Node::Layer)
      end

      it "should ignore leading slashes" do
        expect(@tree.children_at_path('/Version A/Matte').size).to eq(1)
      end

      it "should return an empty array when a node is not found" do
        expect(@tree.children_at_path('NOPE')).to be_an_instance_of(Array)
        expect(@tree.children_at_path('NOPE').size).to eq(0)
      end
    end
  end
end