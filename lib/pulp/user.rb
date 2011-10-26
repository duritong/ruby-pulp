module Pulp
  class User < Pulp::Connection::Base
    
    has_collection
    has_create
    has_get
    has_delete
    
    
    pulp_fields :login, :password, :name, :roles
  end
end