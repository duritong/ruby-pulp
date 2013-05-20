require 'spec_helper'

class CommonLifecycle
  include Pulp::Common::Lifecycle
  attr_reader :fields
  def initialize(data={})
    @fields = data
  end
end

class TestLifecycle < CommonLifecycle
  pulp_field :normal_field
  pulp_field :locked_field, :locked => true
  pulp_field :options_field, :bla => true

  pulp_fields :multiple_field1, :multiple_field2

  pulp_locked_field :locked_field1
  pulp_locked_field :locked_field1a, :foo => true
  pulp_locked_fields :locked_field2, :locked_field3

  pulp_special_field :special_field1
  pulp_special_field :special_field1a, :foo => true
  pulp_special_fields :special_field2, :special_field3
end

class Pulp::ActionLifecycle < CommonLifecycle
  pulp_action :action1
  pulp_action :action2, :method => :get
  pulp_action :action3, :params => false
  pulp_action :action4, :params => :optional
  pulp_action :action5, :returns => Pulp::ActionLifecycle
  pulp_action :action6, :append_slash => false
  pulp_action :action7, :task_list => true
  pulp_action :action8, :parse => false

  def id
    "foo"
  end
end

class Pulp::DeferredLifecycle < CommonLifecycle
  pulp_deferred_field :deferred1
  pulp_deferred_field :deferred2, :array => Pulp::DeferredLifecycle
  pulp_deferred_field :deferred3, :returns => :plain
  pulp_deferred_field :deferred4, :returns => Pulp::DeferredLifecycle

  def id
    "foo"
  end
end

class CollectionLifecycle < CommonLifecycle
  has_collection
end

class CollectionOptionLifecycle < CommonLifecycle
  has_collection :all_filters => [ :foo, :bla ]
end

class GetLifecycle < CommonLifecycle
    has_get
end

class DeleteLifecycle < CommonLifecycle
    has_delete
end

class UpdateLifecycle < CommonLifecycle
    has_update
end

class CreateLifecycle < CommonLifecycle
    has_create
end

class CrudLifecycle < CommonLifecycle
    has_crud
end

describe Pulp::Common::Lifecycle do
  let(:instance){ TestLifecycle.new('options_field' => 'default') }
  describe ".pulp_field" do
    context "normal_field" do
      it "should generate getters for it" do
        instance.should respond_to(:normal_field)
      end
      it "should generate setters for it" do
        instance.should respond_to(:normal_field=)
      end
    end
    context "locked_field" do
      it "should have a getter" do
        instance.should respond_to(:locked_field)
      end
      it "should not have a setter" do
        instance.should_not respond_to(:locked_field=)
      end
    end
    context "options_field" do
      it "should register the options" do
        instance.record_fields[:options_field][:bla].should be_true
      end
    end
    describe "getter" do
      context "nothing yet set" do
        it "should return the initial value" do
          instance.options_field.should eql('default')
        end
        it "should be nil without an initial value" do
          instance.normal_field.should be_nil
        end
      end
      context "something set" do
        it "should return the new value instead of the initial value" do
          instance.options_field = 'new'
          instance.options_field.should eql('new')
        end
        it "should return the new value instead nil" do
          instance.normal_field = 'new2'
          instance.normal_field.should eql('new2')
        end
      end
    end
  end
  describe ".pulp_fields" do
    it "should set multiple fields" do
      instance.should respond_to(:multiple_field1)
      instance.should respond_to(:multiple_field1=)
      instance.should respond_to(:multiple_field2)
      instance.should respond_to(:multiple_field2=)
    end
  end

  def self.locked_field(field,options = false)
    it "should have a getter" do
      instance.should respond_to(field)
    end
    it "should not have a setter" do
      instance.should_not respond_to(:"#{field}=")
    end
    if options
      it "should merge the options" do
        instance.record_fields[field][:foo].should be_true
      end
    end
    it "should be registered as a locked field" do
      instance.locked_fields.should include(field)
    end
  end

  describe ".pulp_locked_field" do
    locked_field :locked_field1
    locked_field :locked_field1a,true
  end

  describe ".pulp_locked_fields" do
    context "should add multiple locked fields" do
      locked_field :locked_field2
      locked_field :locked_field3
    end
  end

  def self.special_field(field,options=false)
    locked_field field,options
    it "should be registered as special field" do
      instance.special_fields.should include(field)
    end
  end
  describe ".pulp_special_field" do
    special_field :special_field1
    special_field :special_field1a,true
  end
  describe ".pulp_special_fields" do
    context "should add multiple locked fields" do
      special_field :special_field2
      special_field :special_field3
    end
  end

  describe ".has_collection" do
    context "without options" do
      it "should have an .all method" do
        CollectionLifecycle.should respond_to(:all)
      end
      context "executing all" do
        before(:each) do
          CollectionLifecycle.expects(:base_get).with('',nil,nil).returns([{:a => 1},{:b => 2}])
        end
        let(:result) { CollectionLifecycle.all }

        it "should return a collection" do
          result.should be_kind_of(Array)
        end

        it "should contain the result" do
          result.first.fields[:a].should eql(1)
          result.last.fields[:b].should eql(2)
        end
      end
    end
    context "with finder options" do
      it "should have an .all method" do
        CollectionOptionLifecycle.should respond_to(:all)
      end
      it "should additionaly have finder options" do
        CollectionOptionLifecycle.should respond_to(:find_by_foo)
        CollectionOptionLifecycle.should respond_to(:find_by_bla)
      end
      context "executing the finder options" do
        it "should call the index get with these options" do
          CollectionOptionLifecycle.expects(:base_get).with('',nil,{:foo => 22}).returns([{:a => 1},{:b => 2}])
          CollectionOptionLifecycle.find_by_foo(22).size.should eql(2)
        end
      end
    end
  end
  [:delete,:create,:get,:update].each do |action|
    describe ".has_#{action}" do
      it "should include the correct module" do
        "#{action.to_s.classify}Lifecycle".constantize.included_modules.should include("Pulp::Common::Lifecycle::#{action.to_s.classify}".constantize)
      end
    end
  end

  describe ".has_crud" do

    context "without options" do
      it "should have an .all method" do
        CrudLifecycle.should respond_to(:all)
      end
      context "executing all" do
        before(:each) do
          CrudLifecycle.expects(:base_get).with('',nil,nil).returns([{:a => 1},{:b => 2}])
        end
        let(:result) { CrudLifecycle.all }

        it "should return a collection" do
          result.should be_kind_of(Array)
        end

        it "should contain the result" do
          result.first.fields[:a].should eql(1)
          result.last.fields[:b].should eql(2)
        end
      end
    end
    [:delete,:create,:get,:update].each do |mod|
      it "should include the #{mod} module" do
        CrudLifecycle.included_modules.should include("Pulp::Common::Lifecycle::#{mod.to_s.classify}".constantize)
      end
    end
  end

  #class Pulp::ActionLifecycle < CommonLifecycle
  #  pulp_action :action1
  #  pulp_action :action2, :method => :get
  #  pulp_action :action3, :params => false
  #  pulp_action :action4, :params => :optional
  #  pulp_action :action5, :returns => Pulp::ActionLifecycle
  #  pulp_action :action6, :append_slash => false
  #  pulp_action :action7, :task_list => true
  #  pulp_action :action8, :parse => false
  #end
  describe ".pulp_action" do
    (1..8).each do |i|
      it "should add a method #action#{i}" do
        Pulp::ActionLifecycle.new('ffo').should respond_to(:"action#{i}")

      end
    end
    context "without any options" do
      it "should call post, add a slash" do
        Pulp::ActionLifecycle.expects(:base_post).with('action1/','foo','aa').returns("foo")
        Pulp::ActionLifecycle.new('ffo').action1('aa').should eql('foo')
      end

      it "should also require params" do
        lambda{ Pulp::ActionLifecycle.new('ffo').action1 }.should(raise_error(ArgumentError))
      end
    end

    context "with a method option" do
      it "should call the exact method, add a slash" do
        Pulp::ActionLifecycle.expects(:base_get).with('action2/','foo','aa').returns("foo")
        Pulp::ActionLifecycle.new('ffo').action2('aa').should eql('foo')
      end
    end

    context "without any params" do
      it "should not allow any params" do
        Pulp::ActionLifecycle.expects(:base_post).returns "blub"
        Pulp::ActionLifecycle.new('ffo').action3.should == 'blub'
        lambda{ Pulp::ActionLifecycle.new('ffo').action3(1) }.should(raise_error(ArgumentError))
      end
    end

    context "with optional params" do
      it "should allow all or none params" do
        Pulp::ActionLifecycle.expects(:base_post).twice
        lambda{ Pulp::ActionLifecycle.new('ffo').action4 }.should_not(raise_error(ArgumentError))
        lambda{ Pulp::ActionLifecycle.new('ffo').action4(1) }.should_not(raise_error(ArgumentError))
      end
    end

    context "with a returns" do
      it "should return a new object of type returns" do
        Pulp::ActionLifecycle.expects(:base_post).returns "blub"
        a = Pulp::ActionLifecycle.new('ffo').action5('aa')
        a.should be_kind_of(Pulp::ActionLifecycle)
      end
    end

    context "without adding a slash" do
      it "should call post but without a slash" do
        Pulp::ActionLifecycle.expects(:base_post).with('action6','foo','aa').returns("foo")
        Pulp::ActionLifecycle.new('ffo').action6('aa').should eql('foo')
      end
    end

    context "with a task lists" do
      it "gets a get method for tasks" do
        Pulp::ActionLifecycle.expects(:base_get).with('action7/','foo',nil).returns(["foo"])
        (a=Pulp::ActionLifecycle.new('ffo').action7_tasks).should be_kind_of(Array)
        a.first.should be_kind_of(Pulp::Task)
      end
    end

    context "without parsing" do
      it "should call an unparsed post" do
        Pulp::ActionLifecycle.expects(:base_unparsed_post).with('action8/','foo','aa').returns("foo")
        Pulp::ActionLifecycle.new('ffo').action8('aa').should eql('foo')
      end
    end
  end

#class Pulp::DeferredLifecycle < CommonLifecycle
#  pulp_action :deferred1
#  pulp_action :deferred2, :array => Pulp::DeferredLifecycle
#  pulp_action :deferred3, :returns => :plain
#  pulp_action :deferred4, :returns => Pulp::DeferredLifecycle
#
#  def id
#    "foo"
#  end
#end
  describe ".pulp_deferred_field" do
    (1..4).each do |i|
      it "provides a method for the deferred field name deferred#{i}" do
        Pulp::DeferredLifecycle.new('a').should respond_to(:"deferred#{i}")
      end

      it "should have a method to obtain the link for deferred#{i}" do
        Pulp::DeferredLifecycle.new("deferred#{i}" => 'a').send(:"deferred#{i}_link").should eql('a')
      end
    end
    context "without any options" do
      it "should return what it gets" do
        Pulp::DeferredLifecycle.expects(:plain_get).with('a',nil,nil).returns('foo')
        Pulp::DeferredLifecycle.new('deferred1' => 'a').deferred1.should eql('foo')
      end
    end

    context "with an array to return" do
      it "should return an array with these types" do
        Pulp::DeferredLifecycle.expects(:plain_get).with('a',nil,nil).returns(['foo1','foo2'])
        (a = Pulp::DeferredLifecycle.new('deferred2' => 'a').deferred2).size.should eql(2)
        a.first.should be_kind_of(Pulp::DeferredLifecycle)
        a.first.fields.should eql('foo1')
      end
    end

    context "with a plain return" do
      it "should return what it gets from the plain connection" do
        a = Object.new
        b = Object.new
        b.expects(:get).returns('ff')
        a.expects(:connection).returns(Hash.new(b))
        Pulp::DeferredLifecycle.expects(:plain_base).returns(a)
        Pulp::DeferredLifecycle.new('deferred3' => 'a').deferred3.should eql('ff')
      end
    end

    context "with an object returns" do
      it "should return an instance of that object" do
        Pulp::DeferredLifecycle.expects(:plain_get).with('a',nil,nil).returns('foo1' => 2)
        Pulp::DeferredLifecycle.new('deferred4' => 'a').deferred4.fields['foo1'].should eql(2)
      end
    end
  end

end
