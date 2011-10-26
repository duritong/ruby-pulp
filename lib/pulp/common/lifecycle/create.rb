module Pulp
  module Common
    module Lifecycle
      module Create
        def self.included(base)
          base.extend ClassMethods
        end
        module ClassMethods
          def create(fields)
            self.new(base_post('',nil,fields))
          end
        end
      end
    end
  end
end
