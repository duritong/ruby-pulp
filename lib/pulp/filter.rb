module Pulp
  class Filter < Pulp::Connection::Base
    
    has_collection
    has_create
    has_get
    has_delete
    
    
    pulp_fields :description, :type, :package_list
    
  end
end