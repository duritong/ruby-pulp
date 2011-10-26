module Pulp
  module Connection
    class Base
      include Pulp::Common::Lifecycle
      
      pulp_special_fields :_id, :id
      
      def initialize(data={})
        @fields = data
      end
      
      class << self
        attr_accessor :hostname, :username, :password, :https

        def reset
          Pulp::Connection::Handler.reset_instance(self.identifier)
        end

        def identifier
          @identifier ||= name.demodulize.downcase
        end

        def plain_get(cmd, params=nil)
          plain_base.parsed{|conn| conn[cmd.sub(/^#{Regexp.escape(plain_base.api_path)}\//,'')].get(merge_params(params)) }
        end
        
        def base_get(cmd,item=nil,params=nil)
          base.parsed{|conn| conn[parse_item_cmd(item,cmd)].get(merge_params(params)) }
        end
        
        def base_delete(cmd,item=nil,params=nil)
          base.parsed{|conn| conn[parse_item_cmd(item,cmd)].delete(merge_params(params)) }
        end
        
        def base_post(cmd,item=nil,params=nil)
          base.parsed{|conn| conn[parse_item_cmd(item,cmd)].post(params.nil? ? nil : params.to_json, :content_type => :json ) }
        end
        def base_put(cmd,item=nil,params=nil)
          base.parsed{|conn| conn[parse_item_cmd(item,cmd)].put(params.nil? ? nil : params.to_json, :content_type => :json ) }
        end
        
        def base
          Pulp::Connection::Handler.instance_for(self.identifier, hostname, username, password, (https.nil? ? true : https))
        end
        
        def plain_base
          Pulp::Connection::Handler.instance_for('', hostname, username, password, (https.nil? ? true : https))
        end
        
        def parse_item_cmd(item,cmd)
          "#{"/#{item}" unless item.nil?}#{(cmd =~ /^\//) ? cmd : "/#{cmd}"}"
        end
        
        def merge_params(params)
          params.nil? ? {} : { :params => params }
        end
      end
    end
  end
end
