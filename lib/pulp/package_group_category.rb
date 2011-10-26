module Pulp
  class PackageGroupCategory < Pulp::Connection::Base
    
    pulp_locked_fields :description, :repo_defined, :display_order, :immutable, :translated_name,
      :packagegroupids, :translated_description, :name
  end
end