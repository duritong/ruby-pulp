#! /usr/bin/env ruby
require File.dirname(__FILE__) + '/../../spec_helper'

class TestDebug
    include Pulp::Common::Debug
end

describe Pulp::Common::Debug do
    it "should provide a way to set and query a debug flag" do
        TestDebug.should respond_to(:debug_enabled)
        TestDebug.should respond_to(:debug_enabled=)
    end

    it "should provide a way to set and query an output engine" do
        TestDebug.should respond_to(:output)
        TestDebug.should respond_to(:output=)
    end    
    
    it "should provide a method to print debug messages on class and instance level" do
        TestDebug.should respond_to(:debug)
        TestDebug.new.should respond_to(:debug)
    end
    
    it "should not have debugging enabled by default" do
        TestDebug.debug_enabled.should == false
    end
    
    it "should not print out a debug message if the debug flag is not set" do
        output = Object.new
        output.expects(:puts).with('foo').never
        TestDebug.output = output
        TestDebug.debug('foo')
    end

    it "should print out a debug message if the debug flag is set" do
        TestDebug.debug_enabled = true
        output = Object.new
        output.expects(:puts).with('foo').once
        TestDebug.output = output
        TestDebug.debug('foo')
    end
end