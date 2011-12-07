base = File.expand_path(File.join(File.dirname(__FILE__), ".."))
$LOAD_PATH << File.join(base, "lib")
$LOAD_PATH << File.join(base, "examples")

puts <<EOS
Pulp examples: Repositories
---------------------------

This will do a simple workflow through the management of repositories via the PULP Api using our ruby wrapper.

It will either use the test_pulp.yml file in this directory or use the PULP_YML environment variable, so you can set it to your own.

The test_pulp.yml file assumes that you have a pulp server running on localhost with username and password set to admin.

It will:
 * Basic operations:
   * list all existing repositories
   * create a repository from the offical pulp repository for RHEL 6 - with a random prefix
   * list all x86_64 repositories via a search filter
   * relist all repositories
   * run a sync on the created repository and wait till the sync finished
   * make a clone of said repository
   * list all repositories
 * Additional Operations:
   * unpublish the cloned repository
   * Adjust the name of the created repository
   * Add a note to the created repository
   * Update this note
   * Delete the note
   * Add a group to the cloned repository
   * Remove that group
   * Add a filter to the cloned repository
   * Remove that filter
   * Republish the cloned repository
 * Cleanup operations
   * Delete the cloned repository
   * Delete the created repository
   * Print all repositories
   
 Do you like to start? (y/n)  
EOS

exit 1 unless STDIN.gets.chomp == 'y'

ENV['PULP_YML'] ||= File.expand_path(File.join(File.dirname(__FILE__), 'test_pulp.yml'))
require 'pulp'

def field_sizes
    @field_sizes ||= Hash.new(12).merge('id' => 27)
end
def fields
  @fields ||= ['id', 'name', 'arch', 'source', 'release', 'last_sync', 'publish']
end
def pretty_table_row(obj = nil)
    '| ' + fields.collect{|field| sprintf("%0-#{field_sizes[field]}s", (obj ? obj.send(field).inspect : field).to_s[0..field_sizes[field]-1]) }.join(' | ') + ' |'
end

def print_repos(repos=Pulp::Repository.all)
  header = pretty_table_row
  [header,header.gsub(/./, '-'), repos.collect{|r| pretty_table_row(r) },header.gsub(/./, '-')].flatten.join("\n")
end
  
puts print_repos
random_id = "pulp-rhel6-x86_64-#{8.times.collect{|a| (65 + rand(25)).chr}.join('')}"

puts "Creating repository"
repo = Pulp::Repository.create(
  :id => random_id,
  :name => 'Example Repository for pulp on RHEL 6 x86_64',
  :arch => 'x86_64',
  :feed => "http://repos.fedorapeople.org/repos/pulp/pulp/6Server/x86_64/",
  :relative_path => "pulp_test/#{random_id}",
  :sync_schedule => '' 
)
puts print_repos

puts "All x86_64 repos:"
puts print_repos(Pulp::Repository.find_by_arch('x86_64'))

puts "Starting repo sync"

task = repo.sync

puts "Syncing enqueued with task id: #{task.id} and arguments: #{task.args.inspect}"

while ['waiting','running'].include?(task.refresh.state) do
  puts "Task is in state #{task.state} - Will wait for 30s and recheck"
  sleep 30
end

puts "Task finished with state: #{task.state}"
if task.exception
  puts "The following exception occured: #{task.exception}"
end

puts "Cloning repository"

task = repo.clone(
  :clone_id => "clone-#{random_id}",
  :clone_name => "Clone of #{random_id}",
  :feed => 'parent'
)

puts "Cloning with task id: #{task.id} and arguments: #{task.args.inspect}"

while ['waiting','running'].include?(task.refresh.state) do
  puts "Task is in state #{task.state} - Will wait for 30s and recheck"
  sleep 30
end

puts "Task finished with state: #{task.state}"
if task.exception
  puts "The following exception occurred: #{task.exception}"
end

clone_repo = Pulp::Repository.get("clone-#{random_id}")

puts print_repos

puts "Unpublish the cloned repository"
clone_repo.update_publish(:state => false)
clone_repo.refresh

puts print_repos


puts "Adjust name: #{repo.name}"
repo.name = 'Some other name'
repo.save
puts "New name: #{repo.name}"

puts

puts "Managing notes"
puts "---------------"
puts "Current notes: #{repo.notes.inspect}"
repo.add_note('test_note','foo')
repo.refresh
puts "Current notes: #{repo.notes.inspect}"
repo.update_note('test_note','foo 2')
repo.refresh
puts "Updated notes: #{repo.notes.inspect}"
puts "Delete note"
repo.delete_note('test_note')
repo.refresh
puts "Current notes: #{repo.notes.inspect}"

puts

puts "Managing groups"
puts "---------------"
puts "Current groups: #{repo.groupid.inspect}"
repo.add_group(:addgrp => 'test_group')
repo.refresh
puts "Current groups: #{repo.groupid.inspect}"
puts "Delete groups"
repo.remove_group(:rmgrp => 'test_group')
repo.refresh
puts "Current groups: #{repo.groupid.inspect}"

puts

puts "Managing filters"
puts "----------------"
puts "Init filter"
begin
  filter = nil
  Pulp::Filter.get('wildcard')
rescue RestClient::ResourceNotFound => e
  filter = Pulp::Filter.create(:id => 'wildcard', :description => 'discard everything', :type => 'blacklist', :package_list => '*')
end

puts "Current filters: #{clone_repo.filters.inspect}"
puts "Adding filter 'wildcard'"
clone_repo.add_filters(:filters => ['wildcard'])
clone_repo.refresh
puts "Current filters: #{clone_repo.filters.inspect}"
puts "Delete filter"
clone_repo.remove_filters(:filters => ['wildcard'])
clone_repo.refresh
puts "Current filters: #{clone_repo.filters.inspect}"

if filter
  puts "Removing filter as it have been created by us"
  filter.delete
end

puts

puts "Republish the cloned repository"
clone_repo.update_publish(:state => true)
clone_repo.refresh

puts print_repos

puts

puts "Deleting repository"

repo.delete
clone_repo.delete

puts print_repos

puts "Finished..."