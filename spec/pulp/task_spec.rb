#! /usr/bin/env ruby
require File.dirname(__FILE__) + '/../spec_helper'

describe Pulp::Task do
  
  describe ".cancel" do
    it "should cancel the task" do
      Pulp::Task.expects(:base_post).with(1,'cancel/',nil).returns('id' => 2)
      Pulp::Task.cancel(1).id.should eql(2)
    end
  end
  
  describe "#cancel" do
    it "should cancel the task" do
      Pulp::Task.expects(:base_post).with(1,'cancel/',nil).returns('id' => 2)
      Pulp::Task.new('id' => 1).cancel.id.should eql(2)
    end
  end
  
  describe ".delete_snapshot" do
    it "should delete the snapshot" do
      Pulp::Task.expects(:base_delete).with(1,'snapshot/',nil).returns('id' => 2)
      Pulp::Task.delete_snapshot(1).id.should eql(2)
    end
  end
  
  describe "#delete_snapshot" do
    it "should delete the snapshot" do
      Pulp::Task.expects(:base_delete).with(1,'snapshot/',nil).returns('id' => 2)
      Pulp::Task.new('id' => 1).delete_snapshot.id.should eql(2)
    end
  end
  
    describe ".snapshot" do
    it "get a snapshot of the task" do
      Pulp::Task.expects(:base_get).with(1,'snapshot/',nil).returns('id' => 2)
      Pulp::Task.snapshot(1).id.should eql(2)
    end
  end
  
  describe "#snapshot" do
    it "should get the snapshot" do
      Pulp::Task.expects(:base_get).with(1,'snapshot/',nil).returns('id' => 2)
      Pulp::Task.new('id' => 1).snapshot.id.should eql(2)
    end
  end
  
end
