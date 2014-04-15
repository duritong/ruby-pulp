module Pulp
  module Connection
    class Handler
      
      include Pulp::Common::Debug
      
      class << self
        attr_accessor :hostname,:username, :password, :enable_v2

        def instance_for(identifier,h=nil,u=nil,p=nil,https=true,v2=nil)
          instances[identifier] ||= Handler.new(identifier,
                                                h||hostname||'localhost',
                                                u||username||'admin',
                                                p||password||'admin',
                                                https,
                                                v2||enable_v2||false
          )
        end
        
        def reset_instance(identifier)
          instances.delete(identifier)
        end
        
        def reset_all
          @instances = {}
        end
        
        private
        def instances
          @instances ||= {}
        end
      end
      
      def initialize(identifier,hostname,username=nil,password=nil,https=true,enable_v2=nil)
        @identifier = identifier
        @hostname = hostname
        @username = username
        @password = password
        @https = https
        @enable_v2 = enable_v2
      end
      
      def parsed
        JSON.parse((yield self.connection).body)
      end
      
      def connection
        @connection ||= RestClient::Resource.new(url, :user => @username, :password => @password, :headers => { :accept => :json })
      end

      def api_path
        @enable_v2 ? "/pulp/api/v2" : "/pulp/api"
      end
      
      def url
        @url ||= "#{@https ? 'https' : 'http'}://#{@hostname}#{api_path}/#{@identifier.to_s.pluralize}"
      end
      
    end
  end
end
