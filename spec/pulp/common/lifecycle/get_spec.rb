#! /usr/bin/env ruby
require File.dirname(__FILE__) + '/../../../spec_helper'

class TestGet
  attr_reader :fields
  def initialize(data)
    @fields = data
  end

  def set_fields(field_data)
    @fields = field_data
  end

  def id
    'aa'
  end

  include Pulp::Common::Lifecycle::Get
end

describe Pulp::Common::Lifecycle::Get do
  describe ".get" do
    it "should have a get method" do
      TestGet.should respond_to(:get)
    end
    it "should call get with the passed fields" do
      TestGet.expects(:base_get).with('','aa',nil).returns(:b => 2)
      TestGet.get('aa').fields[:b].should eql(2)
    end
  end
  describe "#refresh" do
    it "should have a refresh method" do
      TestGet.new(1).should respond_to(:refresh)
    end

    it "should refresh the fields" do
      TestGet.expects(:base_get).with('','aa',nil).returns(:b => 2)
      (t=TestGet.new(1)).refresh.should eql(t)
      t.fields[:b].should eql(2)
    end
  end
end
