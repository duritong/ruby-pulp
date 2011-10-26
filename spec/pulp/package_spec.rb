#! /usr/bin/env ruby
require File.dirname(__FILE__) + '/../spec_helper'

describe Pulp::Package do
  
  
  describe ".by_nvrea" do
    it "should get the package via NVREA" do
      Pulp::Package.expects(:base_get).with('n/v/r/e/a',nil,nil).returns('name' => 'package1')
      Pulp::Package.by_nvrea('n','v','r','e','a').name.should eql('package1')
    end
  end
  
end
