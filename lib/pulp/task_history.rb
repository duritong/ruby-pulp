module Pulp
  class TaskHistory < Pulp::Connection::Base
    
    pulp_fields :class_name, :method_name, :args, :kwargs, :state,
                :progress, :result, :exception,
                :traceback, :consecutive_failures,
                :scheduled_time, :start_time, :finished_time
    
  end
end