module Pulp
  module Connection
    class Handler
      
      include Pulp::Common::Debug
      
      class << self
        attr_accessor :hostname,:username, :password
        
        def instance_for(identifier,h=nil,u=nil,p=nil,https=true)
          instances[identifier] ||= Handler.new(identifier,
                                                h||hostname,
                                                u||username,
                                                p||password,
                                                https
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
      
      def initialize(identifier,hostname,username=nil,password=nil,https=true)
        @identifier = identifier
        @hostname = hostname
        @username = username
        @password = password
        @https = https
      end
      
      def parsed
        JSON.parse((yield self.connection).body)
      end
      
      def connection
        @connection ||= RestClient::Resource.new(url, :user => @username, :password => @password, :headers => { :accept => :json })
      end

      def api_path
        "/pulp/api" 
      end
      
      def url
        @url ||= "#{@https ? 'https' : 'http'}://#{@hostname}#{api_path}/#{@identifier.to_s.pluralize}"
      end
      
    end
  end
end
