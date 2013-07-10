require 'spec_helper'

describe "Hierarchy" do
  before(:each) do
    @psd = PSD.new('spec/files/example.psd')
  end

  it "should parse tree" do
    @psd.parse!
    
    tree = @psd.tree.to_hash
    tree.should include :children
    tree[:children].length.should == 3
  end

  describe "Ancestry" do
    before(:each) do
      @psd.parse!
      @tree = @psd.tree
    end

    it "should provide tree traversal methods" do
      @tree.respond_to?(:root).should be_true
      @tree.respond_to?(:siblings).should be_true
      @tree.respond_to?(:descendants).should be_true
      @tree.respond_to?(:subtree).should be_true
    end

    it "should properly identify the root node" do
      @tree.root?.should be_true
      @tree.root.should == @tree
      @tree.children.last.root.should == @tree
    end

    it "should retrieve all descendants of a node" do
      @tree.descendants.size.should == 12
      @tree.descendant_layers.size.should == 9
      @tree.descendant_groups.size.should == 3
      @tree.descendants.first.should_not == @tree
    end

    it "should retreive the entire subtree of a node" do
      @tree.subtree.size.should == 13
      @tree.subtree_layers.size.should == 9
      @tree.subtree_groups.size.should == 3
      @tree.subtree.first.should == @tree
    end

    it "should properly identify the existence of children" do
      @tree.has_children?.should be_true
      @tree.is_childless?.should be_false
      @tree.descendant_layers.first.has_children?.should be_false
      @tree.descendant_layers.first.is_childless?.should be_true
    end

    it "should retrieve all siblings of a node" do
      @tree.children.first.siblings.should == @tree.children
      @tree.children.first.siblings.should include @tree.children.first
      @tree.children.first.has_siblings?.should be_true
      @tree.children.first.is_only_child?.should be_false
    end

    it "should properly calculate node depth" do
      @tree.depth.should == 0
      @tree.descendant_layers.last.depth.should == 2
      @tree.children.first.depth.should == 1
    end
  end
end