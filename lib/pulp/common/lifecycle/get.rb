module Pulp
  module Common
    module Lifecycle
      module Get
        def self.included(base)
          base.extend ClassMethods
        end
        module ClassMethods
          def get(item_id)
            self.new(base_get('',item_id))
          end
        end
      end
    end
  end
end
