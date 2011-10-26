module Pulp
  class Event < Pulp::Connection::Base
    
    has_collection :all_filters => [ :api, :methid, :principal, :field, :limit, :errors_only ]
    
    pulp_fields :timestamp, :principal_type, :principal, :action, :method, :params, :result, :exception, :traceback
  end
end