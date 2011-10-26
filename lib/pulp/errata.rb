module Pulp
  class Errata < Pulp::Connection::Base
    
    has_collection
    has_get
    has_create
    has_delete
    has_get
    
    
    pulp_field :_ns, :locked => true
    pulp_fields :description, :from_str, :immutable, :issued, :pkglist,
      :pushcount, :reboot_suggested, :references, :release, :repo_defined, :status,
      :title, :type, :updated, :version
    
  end
end