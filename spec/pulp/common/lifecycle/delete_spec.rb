#! /usr/bin/env ruby
require File.dirname(__FILE__) + '/../../../spec_helper'

class TestDelete
  attr_reader :fields
  def initialize(fields)
    @fields = fields
  end
  
  def id
    "blub"
  end
  
  include Pulp::Common::Lifecycle::Delete
end

describe Pulp::Common::Lifecycle::Update do
  it "should have a .delete method" do
    TestDelete.should respond_to(:delete)
  end
  
  it "should have a #delete method" do
    TestDelete.new('ff').should respond_to(:delete)
  end
  context "when deleting" do
    before(:each) do
      TestDelete.expects(:base_delete).with('','blub',nil).returns(nil)  
    end
    describe ".delete" do
      it "should call delete with the passed item_id" do
        TestDelete.delete('blub').should be_nil
      end
    end
    describe "#delete" do
      it "should call delete with the own id" do
        TestDelete.new('aa').delete
      end
    end
  end
end