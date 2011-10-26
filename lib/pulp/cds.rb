module Pulp
  class Cds < Pulp::Connection::Base
    
    has_collection
    has_create
    has_get
    has_delete
    has_update
    
    
    pulp_fields :cluster_id, :description, :hostname, :name
    
  end
end