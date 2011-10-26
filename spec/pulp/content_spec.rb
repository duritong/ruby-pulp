#! /usr/bin/env ruby
require File.dirname(__FILE__) + '/../spec_helper'

describe Pulp::Content do
  
  
  describe ".file" do
    it "should get the file content of the passed id" do
      Pulp::Content.expects(:base_get).with('','files/',{:id => 'ff'}).returns('a')
      Pulp::Content.file('ff').should eql('a')
    end
  end
  
  describe ".delete_file" do
    it "shold delete the file with the passed id" do
      Pulp::Content.expects(:base_delete).with('','files/ff/',nil).returns(nil)
      Pulp::Content.delete_file('ff').should be_nil
    end
  end
  
end
