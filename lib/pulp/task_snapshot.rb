module Pulp
  class TaskSnapshot < Pulp::Connection::Base
    
    pulp_fields :class_name, :method_name, :state, :failure_threshold, :cancel_attempts, :callable,
      :args, :kwargs, :progress, :timeout, :schedule_threshold, :_progress_callback, :start_time, :finish_time,
      :result, :exception, :traceback
    
  end
end