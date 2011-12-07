module Pulp
  module Common
    module Lifecycle
      module Delete
        def self.included(base)
          base.extend ClassMethods 
        end
        def delete
          self.class.delete(id)
        end
        module ClassMethods
          def delete_all
            base_unparsed_delete('','')
          end
          
          def delete(item_id)
            base_delete("",item_id)
          end
        end
      end
    end
  end
end
