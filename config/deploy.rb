require 'mongrel_cluster/recipes'

set :application, "cattrack"
set :repository,  "https://jikesrvm.svn.sourceforge.net/svnroot/jikesrvm/cattrack/branches/upgrade-to-rails-2.2"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/webapps/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "legato.watson.ibm.com"
role :web, "legato.watson.ibm.com"
role :db,  "legato.watson.ibm.com", :primary => true

set :user, "cattrack"
set :use_sudo, false

set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"

task :after_update_app_code, :roles => :app do
  db_config = "#{shared_path}/config/database.yml"
  rb_local =  "#{shared_path}/config/local.rb"
  run "cp #{db_config} #{current_path}/config/database.yml"  
  run "cp #{rb_local} #{current_path}/config/local.rb"
end
