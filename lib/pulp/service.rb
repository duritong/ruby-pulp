module Pulp
  class Service < Pulp::Connection::Base
    
    def self.dependencies(pkgnames,repoids)
      base_post('','dependencies/',{:pkgnames => pkgnames, :repoids => repoids})
    end
    
    def self.search_package(params)
      base_post('','search/packages/',params)
    end
    
    def self.start_upload(name,size,checksum,id=nil)
      params = {
        :name => name,
        :size => size,
        :checksum => checksum
      }
      params[:id] = id unless id.nil?
      base_post('','upload',params)
    end
    
    def self.append_file_content(id,data)
      base_unparsed_put('',"upload/append/#{id}",data,true)
    end
    
    def self.import_file(uploadid, metadata)
      base_post('','upload/import',{:uploadid => uploadid, :metadata => metadata})
    end
    
    def self.package_checksum(pkglist)
      base_put('','packages/checksum/',pkglist)
    end
    
    def self.file_checksum(filelist)
      base_put('','files/checksum/',filelist)
    end
    
    def self.associate_packages(package_info)
      base_post('','associate/packages/',package_info)
    end
    
    def self.repo_discovery(url,type,cert_data)
      Pulp::Task.new(base_post('','discovery/repo/',{:url => url, :type => type, :cert_data => cert_data }))
    end
    
    def self.repo_discovery_staus(taskid)
      Pulp::Task.new(base_get('',"discovery/repo/#{taskid}"))
    end
  end
end
