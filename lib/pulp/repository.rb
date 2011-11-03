module Pulp
  # Create Repository:
  #   Minimum Options to create a repository:
  #   r = Pulp::Repository.create(:feed => "http://mirror.switch.ch/ftp/mirror/epel/6/x86_64/", :id => 'epel-6-x86_64', :name => 'epel-6-x86_64', :arch => 'x86_64')
  class Repository < Pulp::Connection::Base
    has_crud :collection => { :all_filters => [ :id, :name, :arch, :groupid, :relative_path, :notes ] }

    pulp_fields :arch, :checksum_type, :clone_ids,
      :consumer_ca, :consumer_cert,
      :content_types,
      :distributionid, :files_count,
      :filters, :name,
      :package_count, :preserve_metadata,
      :publish, :relative_path,
      :sync_schedule, :use_symlinks

    #these can't be updated
    pulp_locked_fields :feed_ca, :feed_cert, :feed_key, :notes, :source, :groupid, :last_sync

    #special fields
    pulp_deferred_fields :files, :keys, :uri_ref
    
    pulp_deferred_field :comps, :returns => :plain
    pulp_deferred_field :errata, :array => Pulp::Errata, :filters => true
    pulp_deferred_field :distribution, :returns => Pulp::Distribution
    pulp_deferred_field :packagegroupcategories, :array => Pulp::PackageGroupCategory, :filter => true
    pulp_deferred_field :packagegroups, :array => Pulp::PackageGroup, :filter => true
    pulp_deferred_field :packages, :array => Pulp::Package, :filter => true
    
    pulp_action :sync, :returns => Pulp::Task, :params => :optional, :task_list => true
    pulp_action :add_errata
    pulp_action :add_file
    pulp_action :add_filters
    pulp_action :add_group, :parse => false
    pulp_action :add_metadata
    pulp_action :add_package
    pulp_action :add_packagegroup_to_category
    pulp_action :add_packages_to_group
    pulp_action :add_keys
    pulp_action :clone, :returns => Pulp::Task, :task_list => true
    pulp_action :create_packagegroup, :returns => Pulp::PackageGroup
    pulp_action :create_packagegroupcategory, :returns => Pulp::PackageGroupCategory
    pulp_action :delete_errata
    pulp_action :delete_package
    pulp_action :delete_package_from_group
    pulp_action :delete_packagegroup
    pulp_action :delete_packagegroup_from_category
    pulp_action :delete_packagegroupcategory
    pulp_action :download_metadata
    pulp_action :export, :returns => Pulp::Task, :task_list => true
    pulp_action :generate_metadata, :returns => Pulp::Task, :task_list => true
    pulp_action :get_package_by_filename
    pulp_action :get_package_by_nvrea
    pulp_action :import_comps
    pulp_action :list_metadata
    pulp_action :remove_file
    pulp_action :remove_filters
    pulp_action :remove_group, :parse => false
    pulp_action :remove_metadata
    pulp_action :rmkeys
    pulp_action :update_publish
    pulp_action :upload
    
    pulp_action :list_distribution, :method => :get, :append_slash => false
    
    def self.schedules
      self.base_get('schedules/')
    end
    
    def add_note(key,note)
      self.new(self.class.base_post('notes/',self.id,{:key => key, :value => value}))
    end
    
    def delete_note(key)
      self.class.base_delete("notes/#{key}/",self.id)
    end
    
    def update_note(key,new_value)
      self.new(self.class.base_put("notes/#{key}/",self.id,new_value))
    end
  end
end