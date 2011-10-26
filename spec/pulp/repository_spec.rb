#! /usr/bin/env ruby
require File.dirname(__FILE__) + '/../spec_helper'

describe Pulp::Repository do
  
  
  describe ".schedules" do
    it "should get all schedules" do
      Pulp::Repository.expects(:base_get).with('schedules/',nil,nil).returns(1)
      Pulp::Repository.schedules.should eql(1)
    end
  end
  
end
