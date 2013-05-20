require 'spec_helper'

class TestUpdate
  attr_reader :fields
  def initialize(fields)
    @fields = fields
  end

  def id
    "blub"
  end

  include Pulp::Common::Lifecycle::Update

  def self.special_fields
    [:b]
  end

  def user_fields
    { :a => 3, :b => 2}
  end
end

describe Pulp::Common::Lifecycle::Update do
  it "should have a update method" do
    TestUpdate.should respond_to(:update)
  end

  it "should have a save method" do
    TestUpdate.new('ff').should respond_to(:save)
  end
  context "when saving" do
    before(:each) do
      TestUpdate.expects(:base_put).with('','blub',{:a => 3}).returns(:b => 2)
    end
    describe ".update" do
      it "should call put with the passed fields" do
        TestUpdate.update('blub',{:a => 3}).fields[:b].should eql(2)
      end
    end
    describe "#save" do
      it "should call put with the user_fields fields that are not special fields" do
        TestUpdate.new('aa').save.fields[:b].should eql(2)
      end
    end
  end
end