require 'mongrel_cluster/recipes'

set :application, "cattrack"
set :repository,  "https://jikesrvm.svn.sourceforge.net/svnroot/jikesrvm/cattrack/trunk"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/home/cattrack/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "rocoto.anu.edu.au"
role :web, "rocoto.anu.edu.au"
role :db,  "rocoto.anu.edu.au", :primary => true

set :user, "cattrack"
set :use_sudo, false

set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"

task :copy_external_resources, :roles => :app do
  run "cp #{shared_path}/config/database.yml #{release_path}/config/database.yml"  
  run "cp #{shared_path}/config/local.rb #{release_path}/config/local.rb"
  run "cp #{shared_path}/resources/favicon.ico #{release_path}/public/favicon.ico"  
end

after "deploy:update_code", :copy_external_resources

