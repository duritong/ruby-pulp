module Pulp
  class Consumergroup < Pulp::Connection::Base
    
    has_collection
    has_delete
    has_create
    has_get
    
    pulp_fields :description, :consumerids
    
    pulp_action :add
    pulp_action :remove
    pulp_action :bind
    pulp_action :unbind
    pulp_action :add_key_value_pair
    pulp_action :update_key_value_pair
    pulp_action :delete_key_value_pair
    
    #from errata
    pulp_action :installerrata, :method => :get
  end
end