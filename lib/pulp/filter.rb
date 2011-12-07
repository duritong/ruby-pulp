module Pulp
  class Filter < Pulp::Connection::Base

    has_collection
    has_create
    has_get

    pulp_fields :description, :type, :package_list

    def delete(force=false)
      self.class.delete(id,force)
    end

    def self.delete(item_id,force=false)
      base_delete("",item_id, :force => force)
    end

  end
end
