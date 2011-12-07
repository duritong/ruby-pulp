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
                    self.output = self.output # reset output to activate it
                end
                
                def output=(o)
                    @output = o
                    RestClient.log = debug_enabled ? output : nil
                end
                
                def output
                    @output ||= STDERR
                end
                
                def debug(msg)
                    output.puts msg if @debug_enabled
                end
            end
        end
    end
end