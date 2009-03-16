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
  map.connect 'results/:host_name/:test_run_variant/:test_run_id/build_target', :controller => 'results/build_target', :action => 'show', :conditions => {:method => :get}
  map.connect 'results/:host_name/:test_run_variant/:test_run_id/summary', :controller => 'results/test_run', :action => 'show_summary', :conditions => {:method => :get}
  map.connect 'results/:host_name/:test_run_variant/:test_run_id/regression_report', :controller => 'results/test_run', :action => 'regression_report', :conditions => {:method => :get}
  map.connect 'results/:host_name/:test_run_variant/:test_run_id/performance_report', :controller => 'results/test_run', :action => 'performance_report', :conditions => {:method => :get}
  map.connect 'results/:host_name/:test_run_variant/:test_run_id/statistics_report', :controller => 'results/test_run', :action => 'statistics_report', :conditions => {:method => :get}
  map.connect 'results/:host_name/:test_run_variant/:test_run_id/:build_configuration_name/:test_configuration_name/:group_name/:test_case_name/Compilation.txt', :controller => 'results/test_case_compilation', :action => 'show', :conditions => {:method => :get}
  map.connect 'results/:host_name/:test_run_variant/:test_run_id/:build_configuration_name/:test_configuration_name/:group_name/:test_case_name/:statistic_key', :controller => 'results/test_case_statistic', :action => 'show', :conditions => {:method => :get}
  map.connect 'results/:host_name/:test_run_variant/:test_run_id/:build_configuration_name/:test_configuration_name/:group_name/:test_case_name/:test_case_execution_name/Output.txt', :controller => 'results/test_case_execution', :action => 'show', :conditions => {:method => :get}
  map.connect 'results/:host_name/:test_run_variant/:test_run_id/:build_configuration_name/:test_configuration_name/:group_name/:test_case_name', :controller => 'results/test_case', :action => 'show', :conditions => {:method => :get}
  map.connect 'results/:host_name/:test_run_variant/:test_run_id/:build_configuration_name/:test_configuration_name/:group_name', :controller => 'results/group', :action => 'show', :conditions => {:method => :get}
  map.connect 'results/:host_name/:test_run_variant/:test_run_id/:build_configuration_name/Output.txt', :controller => 'results/build_configuration', :action => 'show_output', :conditions => {:method => :get}
  map.connect 'results/:host_name/:test_run_variant/:test_run_id/:build_configuration_name/:test_configuration_name', :controller => 'results/test_configuration', :action => 'show', :conditions => {:method => :get}
  map.connect 'results/:host_name/:test_run_variant/:test_run_id/:build_configuration_name', :controller => 'results/build_configuration', :action => 'show', :conditions => {:method => :get}
  map.connect 'results/:host_name/:test_run_variant/:test_run_id', :controller => 'results/test_run', :action => 'show', :conditions => {:method => :get}
  map.connect 'results/:host_name/:test_run_variant/:test_run_id', :controller => 'results/test_run', :action => 'destroy', :conditions => {:method => :delete}
  map.connect 'results/:host_name/:test_run_variant', :controller => 'results/test_run', :action => 'list_by_variant', :conditions => {:method => :get}
  map.connect 'results/hosts', :controller => 'results/host', :action => 'list', :conditions => {:method => :get}
  map.connect 'results/:host_name', :controller => 'results/host', :action => 'show', :conditions => {:method => :get}

  map.connect 'query', :controller => 'results/test_case_execution', :action => 'list_by_matching_output', :conditions => {:method => :get}

  map.connect 'compare', :controller => 'results/compare_runs', :action => 'compare_two_runs', :conditions => {:method => :get}
  map.connect 'compare/:firstRun/:secondRun', :controller => 'results/compare_runs', :action => 'compare_two_runs', :conditions => {:method => :get}


  map.connect 'admin', :controller => 'admin/dashboard', :conditions => {:method => :get}
  map.connect 'admin/sysinfo', :controller => 'admin/sysinfo', :action => 'show', :conditions => {:method => :get}

  map.access_denied 'security/access_denied', :controller => 'security', :action => 'access_denied'
  map.administrators 'security/administrators', :controller => 'security', :action => 'administrators'

  map.connect '', :controller => 'dashboard', :conditions => {:method => :get}

  map.connect 'admin/sysinfo/:action', :controller => 'admin/sysinfo'
  map.connect 'admin/user/:action/:id', :controller => 'admin/user'
  map.connect 'admin/audit_log', :controller => 'admin/audit_log', :action => 'list'
  map.connect 'security/:action/:id', :controller => 'security'

  if RAILS_ENV == 'test'
    map.connect 'application/:action', :controller => 'application'
    map.connect 'admin/base/:action', :controller => 'admin/base'
  end
end
