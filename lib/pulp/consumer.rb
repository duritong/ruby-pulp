module Pulp
  class Consumer < Pulp::Connection::Base
    
    has_crud
    
    pulp_fields :description, :package_profile, :repoids
    
    pulp_action :packages, :method => :get
    pulp_action :certificate, :method => :get
    pulp_action :bind
    pulp_action :unbind
    pulp_action :package_profile
    pulp_action :history, :params => :optional
    pulp_action :add_key_value_pair
    pulp_action :update_key_value_pair
    pulp_action :delete_key_value_pair
    pulp_action :keyvalues, :method => :get
    
    # from errata
    pulp_action :listerrata, :array => :errata
    pulp_action :installerrata, :method => :get
  end
end