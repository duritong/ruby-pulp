require 'spec_helper'

describe Pulp::Connection::Handler do

  [:hostname,:username, :password].each do |field|
    it "provides a way to set and read a default #{field}" do
      Pulp::Connection::Handler.should respond_to("#{field}=")
      Pulp::Connection::Handler.should respond_to("#{field}")
    end
  end

  describe ".instance_for" do
    it "returns an instance of Pulp::Connection::Handler" do
      Pulp::Connection::Handler.instance_for(:foo).should be_a(Pulp::Connection::Handler)
    end

    it "caches the instances" do
      Pulp::Connection::Handler.instance_for(:foo).should eql(Pulp::Connection::Handler.instance_for(:foo))
    end

    it "takes default hostname if no argument is passed" do
      Pulp::Connection::Handler.hostname = 'blub'
      Pulp::Connection::Handler.instance_for(:default_hostname).instance_variable_get('@hostname').should eql('blub')
    end
    it "takes passed hostname" do
      Pulp::Connection::Handler.hostname = 'blub'
      Pulp::Connection::Handler.instance_for(:default_hostname2,'bla').instance_variable_get('@hostname').should eql('bla')
    end

    it "takes default username if no argument is passed" do
      Pulp::Connection::Handler.username = 'user'
      Pulp::Connection::Handler.instance_for(:default_user,'bla').instance_variable_get('@username').should eql('user')
    end
    it "takes passed username" do
      Pulp::Connection::Handler.username = 'user'
      Pulp::Connection::Handler.instance_for(:default_user2,'bla','user2').instance_variable_get('@username').should eql('user2')
    end

    it "takes default password if no argument is passed" do
      Pulp::Connection::Handler.password = 'secret'
      Pulp::Connection::Handler.instance_for(:default_pwd,'bla','user').instance_variable_get('@password').should eql('secret')
    end
    it "takes passed password" do
      Pulp::Connection::Handler.password = 'secret'
      Pulp::Connection::Handler.instance_for(:default_pwd2,'bla','user2','secret2').instance_variable_get('@password').should eql('secret2')
    end

    it "defaults https to true" do
      Pulp::Connection::Handler.instance_for(:default_https,'bla','user','secret2').instance_variable_get('@https').should eql(true)
    end
    it "takes passed https setting" do
      Pulp::Connection::Handler.instance_for(:default_https2,'bla','user2','secret2',false).instance_variable_get('@https').should eql(false)
    end
  end

  describe ".reset" do
    it "removes a cached instance" do
      a = Pulp::Connection::Handler.instance_for(:cache_reset)
      Pulp::Connection::Handler.reset_instance(:cache_reset)
      Pulp::Connection::Handler.instance_for(:cache_reset).should_not eql(a)
    end

    it "does not raise an error on an inexistant instance" do
      lambda { Pulp::Connection::Handler.reset_instance(:blablablabla) }.should_not raise_error
    end
  end
  describe ".reset_all" do
    it "resets all connections" do
      a = Pulp::Connection::Handler.instance_for(:cache_reset)
      Pulp::Connection::Handler.send(:instances).should_not be_empty
      Pulp::Connection::Handler.reset_all
      Pulp::Connection::Handler.send(:instances).should be_empty
    end
  end

  describe "an instance" do
    let(:instance) do
      Pulp::Connection::Handler.hostname = 'localhost'
      Pulp::Connection::Handler.username = 'admin'
      Pulp::Connection::Handler.password = 'admin'
      Pulp::Connection::Handler.instance_for(:instance)
    end
    before(:each) { Pulp::Connection::Handler.reset_all }
    describe "#parsed" do
      it "gets the connection passed" do
        instance.parsed{|conn| conn.should eql(instance.connection); DummyResult }
      end

      it "parses the result" do
        instance.parsed{|conn| DummyResult }['a'].should eql(1)
      end
    end

    describe "#connection" do
      it "'s url should match our url" do
        instance.connection.url.should eql(instance.url)
      end
      it "'s user should match our username" do
        instance.connection.user.should eql(Pulp::Connection::Handler.username)
      end
      it "'s passowrd should match our password" do
        instance.connection.password.should eql(Pulp::Connection::Handler.password)
      end
    end

    describe "#api_path" do
      it "is a fixed apth" do
        instance.api_path.should eql("/pulp/api")
      end
    end

    describe "#url" do
      it "should be a full url depending on the identifier" do
        instance.url.should eql("https://localhost/pulp/api/instances")
      end
      it "should depend on the https flag" do
        i = Pulp::Connection::Handler.instance_for(:second_instance,'localhost','user','password',false)
        i.url.should eql("http://localhost/pulp/api/second_instances")
      end
    end
  end
end