module Pulp
  class Distribution < Pulp::Connection::Base
    
    has_collection
    has_get
    
    # a pulp distribution can't be updated so far
    pulp_locked_fields :arch, :_ns, :description, :family, :files, :url, :relativepath,  :timestamp, :url, :variant, :version
    
  end
end