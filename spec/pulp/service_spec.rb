#! /usr/bin/env ruby
require File.dirname(__FILE__) + '/../spec_helper'

describe Pulp::Service do
  
  
  describe ".dependencies" do
    it "return a list of dependencies" do
      Pulp::Service.expects(:base_post).with('','dependencies/',{:pkgnames => [1], :repoids => [2]}).returns(1)
      Pulp::Service.dependencies([1],[2]).should eql(1)
    end
  end
  
  describe ".search_package" do
    it "should search package" do
      Pulp::Service.expects(:base_post).with('','search/packages/',{:name => 'foo'}).returns(1)
      Pulp::Service.search_package(:name => 'foo').should eql(1)
    end
  end
  
  describe ".start_upload" do
    context "without an id" do
      it "should start a file upload" do
        Pulp::Service.expects(:base_post).with('','upload',{:name => 'foo',:size => 2, :checksum => 'aa'}).returns(1)
        Pulp::Service.start_upload('foo',2,'aa').should eql(1)
      end
    end
    
    context "with an id" do
      it "should start a file upload with the id" do
        Pulp::Service.expects(:base_post).with('','upload',{:name => 'foo',:size => 2, :checksum => 'aa', :id => 1}).returns(1)
        Pulp::Service.start_upload('foo',2,'aa',1).should eql(1)
      end
    end
  end

  describe ".append_file_content" do
    it "should append file content to the specific id" do
      Pulp::Service.expects(:base_unparsed_put).with('','upload/append/1',"content",true).returns(1)
      Pulp::Service.append_file_content(1,'content').should eql(1)
    end
  end
  
  describe ".import_file" do
    it "should import an uploaded file" do
      Pulp::Service.expects(:base_post).with('','upload/import',{:uploadid => 1, :metadata => {:a => 1}}).returns(1)
      Pulp::Service.import_file(1,:a => 1).should eql(1)
    end
  end
  
  describe ".package_checksum" do
    it "lookup package checksums" do
      Pulp::Service.expects(:base_put).with('','packages/checksum/',['package1','package2']).returns(1)
      Pulp::Service.package_checksum(['package1','package2']).should eql(1)
    end
  end
  describe ".file_checksum" do
    it "lookup file checksums" do
      Pulp::Service.expects(:base_put).with('','files/checksum/',['file1','file2']).returns(1)
      Pulp::Service.file_checksum(['file1','file2']).should eql(1)
    end
  end
  
  describe ".associate_package" do
    it "should associate a list of packages with repos" do
      Pulp::Service.expects(:base_post).with('','associate/packages/',[[['file1','checksum1'],['repo1']],[['file2','checksum2'],['repo2','repo3']]]).returns(1)
      Pulp::Service.associate_packages([[['file1','checksum1'],['repo1']],[['file2','checksum2'],['repo2','repo3']]]).should eql(1)
    end
  end
  
  describe ".repo_discovery" do
    it "should create a task to discover a repositories at a given url" do
      Pulp::Service.expects(:base_post).with('','discovery/repo/',{:url => 'url1',:type => 'yum',:cert_data => {:ca => 'ca', :cert => 'cert'}}).returns('id' => 2)
      Pulp::Service.repo_discovery('url1','yum',{:ca => 'ca', :cert => 'cert'}).id.should eql(2)
    end
  end
  
  describe ".repo_discovery_status" do
    it "should give me a result of discovered repos" do
      Pulp::Service.expects(:base_get).with('','discovery/repo/2',nil).returns('id' => 2, 'result' => 'foo')
      Pulp::Service.repo_discovery_status(2).result.should eql('foo')
    end
  end
end

