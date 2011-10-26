module Pulp
  class PackageGroup < Pulp::Connection::Base
    
    pulp_locked_fields :mandatory_package_names, :description, :repo_defined, :default, :display_order,
      :immutable, :user_visible, :translated_name, :translated_description, :conditional_package_names,
      :optional_package_names, :langonly, :name
  end
end