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
  map.connect 'host/:host_id/test_run/:test_run_id/test_configuration/:test_configuration_id/group/:group_id/test_case/:id/Result.txt', :controller => 'test_case', :action => 'show_output'
  map.connect 'host/:host_id/test_run/:test_run_id/test_configuration/:test_configuration_id/group/:group_id/test_case/:id', :controller => 'test_case', :action => 'show'
  map.connect 'host/:host_id/test_run/:test_run_id/test_configuration/:test_configuration_id/group/:id', :controller => 'group', :action => 'show'
  map.connect 'host/:host_id/test_run/:test_run_id/test_configuration/:id', :controller => 'test_configuration', :action => 'show'
  map.connect 'host/:host_id/test_run/:test_run_id/build_run/:id/Result.txt', :controller => 'build_run', :action => 'show_output'
  map.connect 'host/:host_id/test_run/:test_run_id/build_run/:id', :controller => 'build_run', :action => 'show'
  map.connect 'host/:host_id/test_run/:id', :controller => 'test_run', :action => 'show'
  map.connect 'host/:id', :controller => 'host', :action => 'show', :id => /\d/

  map.administrators 'security/administrators', :controller => 'security', :action => 'administrators'
  map.connect '', :controller => 'dashboard'

  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
