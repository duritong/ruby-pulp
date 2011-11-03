module Pulp
  class Cds < Pulp::Connection::Base
    
    has_crud

    pulp_fields :cluster_id, :description, :hostname, :name, :sync_schedule
    
    pulp_locked_fields :repo_ids, :last_sync , :secret, :hearbeat

    pulp_action :associate, :params => true, :returns => Pulp::Task
    pulp_action :unassociate, :params => true, :returns => Pulp::Task

    pulp_action :history, :params => true

    pulp_action :sync, :params => false, :returns => Pulp::Task, :task_list => true

    def history(action)
      self.class.base_get("history/#{action}/",self.id).collect{|th| Pulp::TaskHistory.new(th) }
    end
    
    def repositories
      repo_ids.collect{|repo_id| Pulp::Repository.find_by_id(repo_id).first }.compact
    end
  end
end