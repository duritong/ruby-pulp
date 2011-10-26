module Pulp
  module Common
    module Lifecycle
      module Update
        def self.included(base)
          base.extend ClassMethods
        end
        
        def save
          self.class.update(self.id,user_fields.reject{|key,value| self.class.special_fields.include?(key) })
        end
        
        module ClassMethods
          def update(item,fields)
            self.new(base_put('',item,fields))
          end
        end
      end
    end
  end
end
