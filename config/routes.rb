#
#  This file is part of the Jikes RVM project (http://jikesrvm.org).
#
#  This file is licensed to You under the Common Public License (CPL);
#  You may not use this file except in compliance with the License. You
#  may obtain a copy of the License at
#
#      http://www.opensource.org/licenses/cpl1.0.php
#
#  See the COPYRIGHT.txt file distributed with this work for information
#  regarding copyright ownership.
#
ActionController::Routing::Routes.draw do |map|
  map.connect 'results/host/:host_id/test_run/:test_run_id/test_configuration/:test_configuration_id/group/:group_id/test_case/:id/Result.txt', :controller => 'results/test_case', :action => 'show_output'
  map.connect 'results/host/:host_id/test_run/:test_run_id/test_configuration/:test_configuration_id/group/:group_id/test_case/:id', :controller => 'results/test_case', :action => 'show'
  map.connect 'results/host/:host_id/test_run/:test_run_id/test_configuration/:test_configuration_id/group/:id', :controller => 'results/group', :action => 'show'
  map.connect 'results/host/:host_id/test_run/:test_run_id/test_configuration/:id', :controller => 'results/test_configuration', :action => 'show'
  map.connect 'results/host/:host_id/test_run/:test_run_id/build_configuration/:id/Result.txt', :controller => 'results/build_configuration', :action => 'show_output'
  map.connect 'results/host/:host_id/test_run/:test_run_id/build_configuration/:id', :controller => 'results/build_configuration', :action => 'show'
  map.connect 'results/host/:host_id/test_run/:test_run_id/build_target/:id', :controller => 'results/build_target', :action => 'show'
  map.connect 'results/host/:host_id/test_run/:id', :controller => 'results/test_run', :action => 'show'
  map.connect 'results/host/:host_id/test_run/:id/Summary', :controller => 'results/test_run', :action => 'show_summary'
  map.connect 'results/host/:id', :controller => 'host', :action => 'show', :id => /\d/
  map.connect 'results/hosts', :controller => 'host', :action => 'list'

  map.connect 'admin', :controller => 'admin/dashboard'
  map.connect 'admin/sysinfo', :controller => 'admin/sysinfo', :action => 'show'

  map.access_denied 'security/access_denied', :controller => 'security', :action => 'access_denied'
  map.administrators 'security/administrators', :controller => 'security', :action => 'administrators'

  map.connect '', :controller => 'dashboard'

  map.connect 'admin/user/:action/:id', :controller => 'admin/user'
  map.connect 'security/:action/:id', :controller => 'security'

  map.connect ':controller/:action/:id'
end
