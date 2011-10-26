module Pulp
  class Content < Pulp::Connection::Base
    
    def self.file(fileid)
      base_get('','files/',{:id => fileid})
    end
    
    def self.delete_file(fileid)
      base_delete('',"files/#{fileid}/")
    end
    
    
  end
end