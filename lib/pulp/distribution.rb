module Pulp
  class Distribution < Pulp::Connection::Base
    
    has_collection
    has_get
    
    pulp_field :_ns, :locked => true
    pulp_fields :description, :files, :relativepath
    
  end
end