set :application, "cattrack"
set :repository,  "https://jikesrvm.svn.sourceforge.net/svnroot/jikesrvm/cattrack/branches/upgrade-to-rails-2.2"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/webapps/cattrack"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "legato.watson.ibm.com"
role :web, "legato.watson.ibm.com"
role :db,  "legato.watson.ibm.com", :primary => true

set :user, "cattrack"
set :use_sudo, false



