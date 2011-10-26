module Pulp
    module Common
        module Debug
            def self.included(base)
                base.extend(ClassMethods)
            end
            
            def debug(msg)
                self.class.debug(msg)
            end
            
            module ClassMethods
                def debug_enabled
                    @debug_enabled ||= false
                end
                
                def debug_enabled=(enable)
                    @debug_enabled = enable
                end
                
                def output=(output)
                    @output = output
                end
                
                def output
                    @output ||= STDOUT
                end
                
                def debug(msg)
                    output.puts msg if @debug_enabled
                end
            end
        end
    end
end