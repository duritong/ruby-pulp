module Pulp
  class Package < Pulp::Connection::Base
    
    has_collection
    has_create
    has_get
    has_delete
    
    
    pulp_field :_ns, :locked => true
    pulp_fields :arch, :buildhost, :checksum, :description,
                  :download_url, :epoch, :filename, :group,
                  :license, :name, :provides, :release, :repoids,
                  :repo_defined, :requires, :size, :vendor, :version
                  
    def self.by_nvrea(name,version,release,epoch,arch)
      self.new(base_get("#{name}/#{version}/#{release}/#{epoch}/#{arch}"))
    end
  end
end
