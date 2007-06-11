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
  map.connect 'results/:host_name/:test_run_name.:test_run_id/build_target', :controller => 'results/build_target', :action => 'show'
  map.connect 'results/:host_name/:test_run_name.:test_run_id/summary', :controller => 'results/test_run', :action => 'show_summary'
  map.connect 'results/:host_name/:test_run_name.:test_run_id/:build_configuration_name/:test_configuration_name/:group_name/:test_case_name/Output.txt', :controller => 'results/test_case', :action => 'show_output'
  map.connect 'results/:host_name/:test_run_name.:test_run_id/:build_configuration_name/:test_configuration_name/:group_name/:test_case_name', :controller => 'results/test_case', :action => 'show'
  map.connect 'results/:host_name/:test_run_name.:test_run_id/:build_configuration_name/:test_configuration_name/:group_name', :controller => 'results/group', :action => 'show'
  map.connect 'results/:host_name/:test_run_name.:test_run_id/:build_configuration_name/:test_configuration_name', :controller => 'results/test_configuration', :action => 'show'
  map.connect 'results/:host_name/:test_run_name.:test_run_id/:build_configuration_name/Output.txt', :controller => 'results/build_configuration', :action => 'show_output'
  map.connect 'results/:host_name/:test_run_name.:test_run_id/:build_configuration_name', :controller => 'results/build_configuration', :action => 'show'
  map.connect 'results/:host_name/:test_run_name.:test_run_id', :controller => 'results/test_run', :action => 'show', :conditions => {:method => :get}
  map.connect 'results/:host_name/:test_run_name.:test_run_id', :controller => 'results/test_run', :action => 'destroy', :conditions => {:method => :delete}
  map.connect 'results/hosts', :controller => 'results/host', :action => 'list'
  map.connect 'results/:host_name', :controller => 'results/host', :action => 'show'

  map.connect 'admin', :controller => 'admin/dashboard'
  map.connect 'admin/sysinfo', :controller => 'admin/sysinfo', :action => 'show'

  map.access_denied 'security/access_denied', :controller => 'security', :action => 'access_denied'
  map.administrators 'security/administrators', :controller => 'security', :action => 'administrators'

  map.connect '', :controller => 'dashboard'

  map.connect 'admin/sysinfo/:action', :controller => 'admin/sysinfo'
  map.connect 'admin/user/:action/:id', :controller => 'admin/user'
  map.connect 'security/:action/:id', :controller => 'security'

  map.connect 'reports/:host_name/:test_run_name.:test_run_id', :controller => 'reports/test_run_by_revision_report', :action => 'show', :conditions => {:method => :get}

  map.connect 'explorer', :controller => 'explorer/dashboard', :action => 'index'
  map.connect 'explorer/filter/:action/:id', :controller => 'explorer/filter'
  map.connect 'explorer/report/:action/:id', :controller => 'explorer/report'
  map.connect 'explorer/summarizer/:action/:id', :controller => 'explorer/summarizer'
  if RAILS_ENV == 'test'
    map.connect 'application/:action', :controller => 'application'
    map.connect 'explorer/base/:action', :controller => 'explorer/base'
    map.connect 'admin/base/:action', :controller => 'admin/base'
  end
end
