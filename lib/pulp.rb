require 'rest_client'
require 'json'
require 'active_support/inflector'

require 'pulp/common/debug'
require 'pulp/common/lifecycle'
require 'pulp/common/lifecycle/create'
require 'pulp/common/lifecycle/delete'
require 'pulp/common/lifecycle/get'
require 'pulp/common/lifecycle/update'
require 'pulp/connection/base'
require 'pulp/connection/handler'

# types
%w{consumer consumergroup content distribution errata event filter task_snapshot task
  cds package package_group package_group_category repository service task_history user}.each {|type| require "pulp/#{type}" }

if File.exists?(file=File.expand_path('~/.pulp.yaml')) || File.exists?(file='/etc/pulp/pulp.yaml')
  require 'yaml'
  global_options = YAML.load_file(file)
  Pulp::Connection::Handler.hostname = global_options['hostname']
  Pulp::Connection::Handler.username = global_options['username']
  Pulp::Connection::Handler.password = global_options['password']
end