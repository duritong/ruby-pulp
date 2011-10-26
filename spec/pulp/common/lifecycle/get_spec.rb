#! /usr/bin/env ruby
require File.dirname(__FILE__) + '/../../../spec_helper'

class TestGet
  attr_reader :fields
  def initialize(fields)
    @fields = fields
  end
  
  include Pulp::Common::Lifecycle::Get
end

describe Pulp::Common::Lifecycle::Get do
  it "should have a get method" do
    TestGet.should respond_to(:get)
  end
  it "should call get with the passed fields" do
    TestGet.expects(:base_get).with('','aa',nil).returns(:b => 2)
    TestGet.get('aa').fields[:b].should eql(2)
  end
end