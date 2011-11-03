module Pulp
  module Common
    module Lifecycle
      def self.included(base)
        base.extend ClassMethods
      end
      def fields
        @fields ||= {}
      end
      
      def user_fields
        @user_fields ||= {}
      end
      def record_fields
        self.class.record_fields
      end
      def special_fields
        self.class.special_fields
      end
      
      def locked_fields
        self.class.locked_fields
      end
      
      module ClassMethods
        # Allows for dynamically declaring fields that will come from
        # Cobbler.
        #
        def pulp_field(field,options={})
          locked_fields << field if options[:locked]

          module_eval("def #{field}() user_fields['#{field}'] || fields['#{field}']; end")
          module_eval("def #{field}=(val) user_fields['#{field}'] = val; end") unless options[:locked]
          
          record_fields[field] = options
        end
        
        # Declare many fields at once.
        def pulp_fields(*fields)
          fields.to_a.each {|field| pulp_field(field) }
        end

        def pulp_deferred_field(field,options={})
          if options[:array]
            module_eval("def #{field}() self.class.plain_get(fields['#{field}']).collect{|p| #{options[:array]}.new(p) }; end")
          elsif options[:returns] == :plain
            module_eval("def #{field}() self.class.plain_base.connection[fields['#{field}'].sub(/^\\/pulp\\/api\\//,'')].get; end")
          elsif options[:returns]
            module_eval("def #{field}() (res = self.class.plain_get(fields['#{field}'])).empty? ? nil : #{options[:returns]}.new(res); end")
          else
            module_eval("def #{field}() self.class.plain_get(fields['#{field}']); end")
          end
          module_eval("def #{field}_link() fields['#{field}']; end")
        end
        
        # Declare many deffered fields at once.
        def pulp_deferred_fields(*fields)
          [*fields].each {|field| pulp_deferred_field(field) }
        end
        
        # declare a field that is locked
        def pulp_locked_field(field,options={})
          pulp_field field, options.merge(:locked => true)
        end

        # Declare many locked fields at once.
        def pulp_locked_fields(*fields)
          [*fields].each {|field| pulp_locked_field(field) }
        end
        
        # special fields are locked and registered as being special
        def pulp_special_field(field,options={})
          pulp_locked_field(field,options)
          special_fields << field
        end
        
        #Declare multiple special fields at once
        def pulp_special_fields(*fields)
          [*fields].each{|f| pulp_special_field(f) }
        end
        
        # optional features
        def has_collection(options={})
          
          instance_eval %{ def all
            base_get('').collect {|e| self.new(e) }
          end}
          
          options[:all_filters] && options[:all_filters].each do |filter|
            instance_eval %{
              def find_by_#{filter}(f)
                base_get('',nil,{ :#{filter} => f }).collect {|e| self.new(e) }
              end}
          end
        end
        
        def has_crud(options={})
          has_collection(options[:collection]||{})
          has_create
          has_get
          has_update
          has_delete
        end
        
        def has_delete
          include Pulp::Common::Lifecycle::Delete
        end
        
        def has_create
          include Pulp::Common::Lifecycle::Create
        end
        
        def has_get
          include Pulp::Common::Lifecycle::Get
        end
        
        def has_update
          include Pulp::Common::Lifecycle::Update
        end
        
        def pulp_action(action_name, options={})
          options[:method] ||= :post
          options[:params] = true if options[:params].nil?
          # default is true
          slash = (options[:append_slash].nil? || options[:append_slash]) ? '/' : '' 
          if options[:returns]
            module_eval %{
            def #{action_name}(#{"params#{"={}" if options[:params] == :optional}" if options[:params]})
              #{options[:returns]}.new(self.class.base_#{(options[:parse] == false) ? 'unparsed_' : '' }#{options[:method]}('#{action_name}#{slash}',self.id,#{options[:params] ? 'params' : 'nil' }))
            end}
          else
            module_eval %{
            def #{action_name}(#{"params#{"={}" if options[:params] == :optional}" if options[:params]})
              self.class.base_#{(options[:parse] == false) ? 'unparsed_' : '' }#{options[:method]}('#{action_name}#{slash}',self.id,#{options[:params] ? 'params' : 'nil' })
            end}
          end
          if options[:task_list]
            module_eval %{
              def #{action_name}_tasks
                self.class.base_get('#{action_name}#{slash}',self.id).collect{|p| Pulp::Task.new(p) }
              end}
          end
        end
        
        def special_fields
          @special_fields ||= []
        end
        
        def record_fields
          @record_fields ||= {}
        end
        
        def locked_fields
          @locked_fields ||= []
        end
      end
    end
  end
end