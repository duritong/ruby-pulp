#! /usr/bin/env ruby
require File.dirname(__FILE__) + '/../../../spec_helper'

class TestCreate
  attr_reader :fields
  def initialize(fields)
    @fields = fields
  end
  
  include Pulp::Common::Lifecycle::Create
end

describe Pulp::Common::Lifecycle::Create do
  it "should have a create method" do
    TestCreate.should respond_to(:create)
  end
  it "should call post with the passed fields" do
    TestCreate.expects(:base_post).with('',nil,{:a => 1}).returns(:b => 2)
    TestCreate.create(:a => 1).fields[:b].should eql(2)
  end
end