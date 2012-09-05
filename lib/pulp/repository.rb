module Pulp
  # Create Repository:
  #   Minimum Options to create a repository:
  #   r = Pulp::Repository.create(:feed => "http://mirror.switch.ch/ftp/mirror/epel/6/x86_64/", :id => 'epel-6-x86_64', :name => 'epel-6-x86_64', :arch => 'x86_64')
  class Repository < Pulp::Connection::Base
    has_crud :collection => { :all_filters => [ :id, :name, :arch, :groupid, :relative_path, :notes ] }

    pulp_fields :arch, :name, :release

    #these can't be updated
    pulp_locked_fields  :checksum_type, :clone_ids, :content_types, :feed_ca, :feed_cert, :feed_key,
      :filters, :files_count, :groupid, :last_sync, :publish,
      :consumer_ca, :consumer_cert, :consumer_key ,:distributionid, :notes, :next_scheduled_sync,
      :package_count, :preserve_metadata, :relative_path, :source, :sync_schedule, :use_symlinks, :uri_ref

    #special fields
    pulp_deferred_fields :files, :keys

    pulp_deferred_field :comps, :returns => :plain
    pulp_deferred_field :errata, :array => Pulp::Errata, :filters => true
    pulp_deferred_field :distribution, :array => Pulp::Distribution
    pulp_deferred_field :packagegroupcategories, :array => Pulp::PackageGroupCategory, :filter => true
    pulp_deferred_field :packagegroups, :array => Pulp::PackageGroup, :filter => true
    pulp_deferred_field :packages, :array => Pulp::Package, :filter => true

    pulp_action :sync, :returns => Pulp::Task, :params => :optional, :task_list => true
    pulp_action :add_errata, :parse => false
    pulp_action :add_file, :parse => false
    pulp_action :add_filters, :parse => false
    pulp_action :add_group, :parse => false
    pulp_action :add_metadata, :parse => false
    pulp_action :add_package, :parse => false
    pulp_action :add_packagegroup_to_category, :parse => false
    pulp_action :add_packages_to_group, :parse => false
    pulp_action :add_keys, :parse => false
    pulp_action :clone, :returns => Pulp::Task, :task_list => true
    pulp_action :create_packagegroup, :returns => Pulp::PackageGroup
    pulp_action :create_packagegroupcategory, :returns => Pulp::PackageGroupCategory
    pulp_action :delete_errata, :parse => false
    pulp_action :delete_package, :parse => false
    pulp_action :delete_package_from_group, :parse => false
    pulp_action :delete_packagegroup, :parse => false
    pulp_action :delete_packagegroup_from_category, :parse => false
    pulp_action :delete_packagegroupcategory, :parse => false
    pulp_action :download_metadata, :parse => false
    pulp_action :export, :returns => Pulp::Task, :task_list => true
    pulp_action :generate_metadata, :returns => Pulp::Task, :task_list => true
    pulp_action :get_package_by_filename
    pulp_action :get_package_by_nvrea
    pulp_action :import_comps, :parse => false
    pulp_action :list_metadata
    pulp_action :remove_distribution, :parse => false
    pulp_action :remove_file, :parse => false
    pulp_action :remove_filters, :parse => false
    pulp_action :remove_group, :parse => false
    pulp_action :remove_metadata, :parse => false
    pulp_action :rmkeys, :parse => false
    pulp_action :update_publish, :parse => false
    pulp_action :upload, :parse => false

    pulp_action :list_distribution, :method => :get, :append_slash => false

    def self.schedules
      self.base_get('schedules/')
    end


    def update_sync_schedule(schedule)
      update_schedule('sync',schedule)
    end

    def get_schedule(type)
      self.class.base_get("schedules/#{type}/",id)
    end

    def get_sync_schedule
      get_schedule('sync')
    end

    def delete_schedule(type)
      self.class.base_delete("schedules/#{type}/",id)
    end

    def delete_sync_schedule
      delete_schedule('sync')
    end

    def update_schedule(type,schedule)
      self.class.base_put("schedules/#{type}/",id,{:schedule => schedule})
    end

    def add_note(key,note)
      self.class.base_unparsed_post('notes/',self.id,{:key => key, :value => note})
      refresh
      self
    end

    def delete_note(key)
      self.class.base_unparsed_delete("notes/#{key}/",self.id)
      refresh
      self
    end

    def update_note(key,new_value)
      self.class.base_unparsed_put("notes/#{key}/",self.id,new_value)
      refresh
      self
    end

    pulp_update_action :feed, :params => :feed
    pulp_update_action :feed_cert_data, :params => [:ca, :crt, :key]
    pulp_update_action :consumer_cert_data, :params => [:ca, :crt, :key]
  end
end
