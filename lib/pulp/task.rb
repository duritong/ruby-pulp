module Pulp
  class Task < Pulp::Connection::Base
    
    has_delete
    has_get
    has_collection :all_filters => [:state]
    
    pulp_fields :job_id, :class_name, :method_name, :state, :start_time, :finish_time, :result,
                :exception ,:traceback, :progress, :scheduled_time, :snapshot_id

    pulp_action :snapshots, :method => :get, :array => Pulp::TaskSnapshot

    def cancel
      self.class.cancel(id)
    end
    
    def self.cancel(taskid)
      self.new(base_post(taskid,'cancel/'))
    end
    
    def delete_snapshot
      self.class.delete_snapshot(id)
    end
    
    def self.delete_snapshot(taskid)
      Pulp::TaskSnapshot.new(base_delete(taskid,'snapshot/'))
    end
    
    def snapshot
      self.class.snapshot(id)
    end
    
    def self.snapshot(taskid)
      Pulp::TaskSnapshot.new(base_get(taskid,'snapshot/'))
    end
  end
end