#! /usr/bin/env ruby
require File.dirname(__FILE__) + '/../../spec_helper'

module Pulp
  class Test < Pulp::Connection::Base
  end
end

module Pulp
  class Test2 < Pulp::Connection::Base
  end
end

describe Pulp::Connection::Base do
  describe ".reset" do
    it "resets the used base" do
      a = Pulp::Test.send(:base)
      Pulp::Test.reset
      a.should_not eql(Pulp::Test.send(:base))
    end
  end
  
  describe ".identifier" do
    it "is the downcased class name" do
      Pulp::Test.identifier.should eql('test')
    end
  end
  
  describe ".base" do
    it "differs based on the used class" do
      Pulp::Test.base.should_not eql(Pulp::Test2.send(:base))
    end
  end
  
  describe ".plain_base" do
    it "is without any context" do
      Pulp::Test.plain_base.url.should eql('https://localhost/pulp/api/')
    end
  end
  
  describe ".parse_item_cmd" do
    context "with an item" do
      it "should prefix with an item" do
        Pulp::Test.parse_item_cmd('foo','bla').should eql('/foo/bla')
      end
      it "should not double prefix the cmd" do
        Pulp::Test.parse_item_cmd('foo','/bla').should eql('/foo/bla')
      end
    end
    context "without an item" do
      it "should prefix the cmd with a slash" do
        Pulp::Test.parse_item_cmd(nil,'bla').should eql('/bla')
      end
      it "should not double prefix the cmd" do
        Pulp::Test.parse_item_cmd(nil,'/bla').should eql('/bla')
      end
    end
  end
  
  describe ".merge_params" do
    it "should return an empty hash on no params" do
      Pulp::Test.merge_params(nil).should eql({})
    end
    it "should add the params" do
      Pulp::Test.merge_params({:b => 2}).should eql({ :params => {:b => 2}})
    end
  end
  describe "base actions" do
    before(:each) do
      @context = Object.new
    end
    describe ".plain_get" do
      before(:each) do
        Pulp::Test.plain_base.connection.expects(:[]).with('foo').returns(@context)
      end
      context "without params" do
        before(:each) do
          @context.expects(:get).with({}).returns(DummyResult)  
        end
        it "should return a parsed get" do
          Pulp::Test.plain_get('foo').should eql(DummyResult.real_body)
        end
        it "should strip the api url prefix" do
          Pulp::Test.plain_get('/pulp/api/foo').should eql(DummyResult.real_body)
        end
      end
      context "with params" do
        before(:each) do
          @context.expects(:get).with(:params => { :b => 2}).returns(DummyResult)
        end
        it "should add the params" do
          Pulp::Test.plain_get('/pulp/api/foo',:b => 2).should eql(DummyResult.real_body)
        end
      end
    end
    context "parsed" do
      [:get, :delete ].each do |method|
        describe ".base_#{method}" do
          context "with an item" do
            before(:each) do
              Pulp::Test.base.connection.expects(:[]).with('/blub/foo').returns(@context)
            end
            context "without params" do
              before(:each) do
                @context.expects(method).with({}).returns(DummyResult)
              end
              it "should return a parsed #{method}" do
                Pulp::Test.send(:"base_#{method}",'foo','blub').should eql(DummyResult.real_body)
              end
            end
            context "with a params" do
              before(:each) do
                @context.expects(method).with({ :params => {:b => 2 }}).returns(DummyResult)
              end
              it "should return a parsed #{method}" do
                Pulp::Test.send(:"base_#{method}",'foo','blub',:b => 2).should eql(DummyResult.real_body)
              end
            end
          end
          context "without an item" do
            before(:each) do
              Pulp::Test.base.connection.expects(:[]).with('/foo').returns(@context)
            end
            context "without params" do
              before(:each) do
                @context.expects(method).with({}).returns(DummyResult)
              end
              it "should return a parsed #{method}" do
                Pulp::Test.send(:"base_#{method}",'foo').should eql(DummyResult.real_body)
              end
            end
            context "with params" do
              before(:each) do
                @context.expects(method).with({:params => {:b => 2 }}).returns(DummyResult)
              end
              it "should return a parsed #{method}" do
                Pulp::Test.send(:"base_#{method}",'foo',nil,:b => 2).should eql(DummyResult.real_body)
              end
            end
          end
        end
      end
      [:post,:put].each do |method|
        describe ".base_#{method}" do
          context "with an item" do
            before(:each) do
              Pulp::Test.base.connection.expects(:[]).with('/blub/foo').returns(@context)
            end
            context "without params" do
              before(:each) do
                @context.expects(method).with(nil,{:content_type => :json}).returns(DummyResult)
              end
              it "should return a parsed #{method}" do
                Pulp::Test.send(:"base_#{method}",'foo','blub').should eql(DummyResult.real_body)
              end
            end
            context "with a params" do
              before(:each) do
                @context.expects(method).with({:b => 2 }.to_json,{:content_type => :json}).returns(DummyResult)
              end
              it "should return a parsed #{method}" do
                Pulp::Test.send(:"base_#{method}",'foo','blub',:b => 2).should eql(DummyResult.real_body)
              end
            end
          end
          context "without an item" do
            before(:each) do
              Pulp::Test.base.connection.expects(:[]).with('/foo').returns(@context)
            end
            context "without params" do
              before(:each) do
                @context.expects(method).with(nil,{:content_type => :json}).returns(DummyResult)
              end
              it "should return a parsed #{method}" do
                Pulp::Test.send(:"base_#{method}",'foo').should eql(DummyResult.real_body)
              end
            end
            context "with params" do
              before(:each) do
                @context.expects(method).with({:b => 2 }.to_json, {:content_type => :json}).returns(DummyResult)
              end
              it "should return a parsed #{method}" do
                Pulp::Test.send(:"base_#{method}",'foo',nil,:b => 2).should eql(DummyResult.real_body)
              end
            end
          end
        end
      end
    end
    context "unparsed" do
       [:get, :delete ].each do |method|
        describe ".base_unparsed_#{method}" do
          context "with an item" do
            before(:each) do
              Pulp::Test.base.connection.expects(:[]).with('/blub/foo').returns(@context)
            end
            context "without params" do
              before(:each) do
                @context.expects(method).with({}).returns(UnparsedDummyResult)
              end
              it "should return an unparsed #{method}" do
                Pulp::Test.send(:"base_unparsed_#{method}",'foo','blub').should eql(UnparsedDummyResult.real_body)
              end
            end
            context "with a params" do
              before(:each) do
                @context.expects(method).with({ :params => {:b => 2 }}).returns(UnparsedDummyResult)
              end
              it "should return an unparsed #{method}" do
                Pulp::Test.send(:"base_unparsed_#{method}",'foo','blub',:b => 2).should eql(UnparsedDummyResult.real_body)
              end
            end
          end
          context "without an item" do
            before(:each) do
              Pulp::Test.base.connection.expects(:[]).with('/foo').returns(@context)
            end
            context "without params" do
              before(:each) do
                @context.expects(method).with({}).returns(UnparsedDummyResult)
              end
              it "should return an unparsed #{method}" do
                Pulp::Test.send(:"base_unparsed_#{method}",'foo').should eql(UnparsedDummyResult.real_body)
              end
            end
            context "with params" do
              before(:each) do
                @context.expects(method).with({:params => {:b => 2 }}).returns(UnparsedDummyResult)
              end
              it "should return an unparsed #{method}" do
                Pulp::Test.send(:"base_unparsed_#{method}",'foo',nil,:b => 2).should eql(UnparsedDummyResult.real_body)
              end
            end
          end
        end
      end
      [:post,:put].each do |method|
        describe ".base_#{method}" do
          context "with an item" do
            before(:each) do
              Pulp::Test.base.connection.expects(:[]).with('/blub/foo').returns(@context)
            end
            context "without params" do
              before(:each) do
                @context.expects(method).with(nil,{:content_type => :json}).returns(UnparsedDummyResult)
              end
              it "should return an unparsed #{method}" do
                Pulp::Test.send(:"base_unparsed_#{method}",'foo','blub').should eql(UnparsedDummyResult.real_body)
              end
            end
            context "with a params" do
              before(:each) do
                @context.expects(method).with({:b => 2 }.to_json,{:content_type => :json}).returns(UnparsedDummyResult)
              end
              it "should return a unparsed #{method}" do
                Pulp::Test.send(:"base_unparsed_#{method}",'foo','blub',:b => 2).should eql(UnparsedDummyResult.real_body)
              end
            end
          end
          context "without an item" do
            before(:each) do
              Pulp::Test.base.connection.expects(:[]).with('/foo').returns(@context)
            end
            context "without params" do
              before(:each) do
                @context.expects(method).with(nil,{:content_type => :json}).returns(UnparsedDummyResult)
              end
              it "should return an unparsed #{method}" do
                Pulp::Test.send(:"base_unparsed_#{method}",'foo').should eql(UnparsedDummyResult.real_body)
              end
            end
            context "with params" do
              before(:each) do
                @context.expects(method).with({:b => 2 }.to_json, {:content_type => :json}).returns(UnparsedDummyResult)
              end
              it "should return an unparsed #{method}" do
                Pulp::Test.send(:"base_unparsed_#{method}",'foo',nil,:b => 2).should eql(UnparsedDummyResult.real_body)
              end
            end
          end
        end
      end
    end
  end
  [:hostname,:username, :password].each do |field|
    describe ".#{field}" do
      it "provides a way to set and read a #{field}" do
        Pulp::Test.should respond_to("#{field}=")
        Pulp::Test.should respond_to("#{field}")
      end
      
      it "is used for the base connection" do
        Pulp::Test.reset
        Pulp::Test.send("#{field}=","foo")
        Pulp::Test.send(:base).instance_variable_get("@#{field}").should eql("foo")
      end
    end
  end
  describe "default special fields" do
    [:id, :_id].each do |field|
      it "#{field} is a special_field" do
        Pulp::Connection::Base.special_fields.should include(field)
      end
    end
  end
  
  describe "initialization" do
    it "initializes the fields with the supplied data" do
      Pulp::Test.new(:a => 1).fields[:a].should eql(1)
    end
  end
end