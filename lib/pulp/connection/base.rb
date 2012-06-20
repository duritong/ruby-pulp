module Pulp
  module Connection
    class Base
      include Pulp::Common::Lifecycle
      
      pulp_special_fields :_id, :id
      
      def initialize(data={})
        set_fields(data)
      end

      def set_fields(field_data)
        @fields = field_data
      end

      class << self
        attr_accessor :hostname, :username, :password, :https

        def reset
          Pulp::Connection::Handler.reset_instance(self.identifier)
        end

        def identifier
          @identifier ||= name.demodulize.downcase
        end

        def plain_unparsed_get(cmd, params=nil)
          plain_base.connection[s(cmd.sub(/^#{Regexp.escape(plain_base.api_path)}\//,''))].get(merge_params(params)).body
        end

        def base_unparsed_get(cmd,item=nil,params=nil)
          base.connection[s(parse_item_cmd(item,cmd))].get(merge_params(params)).body
        end

        def base_unparsed_delete(cmd,item=nil,params=nil)
          base.connection[s(parse_item_cmd(item,cmd))].delete(merge_params(params)).body
        end

        def base_unparsed_post(cmd,item=nil,params=nil)
          base.connection[s(parse_item_cmd(item,cmd))].post(params.nil? ? nil : params.to_json, :content_type => :json ).body
        end

        def base_unparsed_put(cmd,item=nil,params=nil,binary_data=false)
          if binary_data
            p = params
            ct = 'application/stream'
          else
            p = params.nil? ? nil : params.to_json
            ct = :json
          end
          base.connection[s(parse_item_cmd(item,cmd))].put(p, :content_type => ct).body
        end

        def plain_get(cmd, params=nil)
          plain_base.parsed{|conn| conn[s(cmd.sub(/^#{Regexp.escape(plain_base.api_path)}\//,''))].get(merge_params(params)) }
        end
        
        def base_get(cmd,item=nil,params=nil)
          base.parsed{|conn| conn[s(parse_item_cmd(item,cmd))].get(merge_params(params)) }
        end
        
        def base_delete(cmd,item=nil,params=nil)
          base.parsed{|conn| conn[s(parse_item_cmd(item,cmd))].delete(merge_params(params)) }
        end
        
        def base_post(cmd,item=nil,params=nil)
          base.parsed{|conn| conn[s(parse_item_cmd(item,cmd))].post(params.nil? ? nil : params.to_json, :content_type => :json ) }
        end
        def base_put(cmd,item=nil,params=nil)
          base.parsed{|conn| conn[s(parse_item_cmd(item,cmd))].put(params.nil? ? nil : params.to_json, :content_type => :json ) }
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

        # sanitize uri
        # if uri is already escaped, we don't do anything, otherwise we escape it.
        def s(uri)
          (URI.decode(uri) != uri) ? uri : URI.escape(uri)
        end
      end
    end
  end
end
