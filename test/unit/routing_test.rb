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
require File.dirname(__FILE__) + '/../test_helper'

class RoutingTest < Test::Unit::TestCase
  def test_routes
    assert_routing('/results/excalibur.watson.ibm.com/core.36/production/Measure_Compilation_Opt_0/SPECjvm98/_200_check/Output.txt', :host_name => 'excalibur.watson.ibm.com', :test_run_name => 'core', :test_run_id => '36', :build_configuration_name => 'production', :test_configuration_name => 'Measure_Compilation_Opt_0', :group_name => 'SPECjvm98', :test_case_name => '_200_check', :controller => 'results/test_case', :action => 'show_output')
    assert_routing('/results/excalibur.watson.ibm.com/core.36/production/Measure_Compilation_Opt_0/SPECjvm98/_200_check', :host_name => 'excalibur.watson.ibm.com', :test_run_name => 'core', :test_run_id => '36', :build_configuration_name => 'production', :test_configuration_name => 'Measure_Compilation_Opt_0', :group_name => 'SPECjvm98', :test_case_name => '_200_check', :controller => 'results/test_case', :action => 'show')
    assert_routing('/results/excalibur.watson.ibm.com/core.36/production/Measure_Compilation_Opt_0/SPECjvm98', :host_name => 'excalibur.watson.ibm.com', :test_run_name => 'core', :test_run_id => '36', :build_configuration_name => 'production', :test_configuration_name => 'Measure_Compilation_Opt_0', :group_name => 'SPECjvm98', :controller => 'results/group', :action => 'show')
    assert_routing('/results/excalibur.watson.ibm.com/core.36/production/Measure_Compilation_Opt_0', :host_name => 'excalibur.watson.ibm.com', :test_run_name => 'core', :test_run_id => '36', :build_configuration_name => 'production', :test_configuration_name => 'Measure_Compilation_Opt_0', :controller => 'results/test_configuration', :action => 'show')
    assert_routing('/results/excalibur.watson.ibm.com/core.36/production', :host_name => 'excalibur.watson.ibm.com', :test_run_name => 'core', :test_run_id => '36', :build_configuration_name => 'production', :controller => 'results/build_configuration', :action => 'show')
    assert_routing('/results/excalibur.watson.ibm.com/core.36/summary', :host_name => 'excalibur.watson.ibm.com', :test_run_name => 'core', :test_run_id => '36', :controller => 'results/test_run', :action => 'show_summary')
    assert_routing('/results/excalibur.watson.ibm.com/core.36/build_target', :host_name => 'excalibur.watson.ibm.com', :test_run_name => 'core', :test_run_id => '36', :controller => 'results/build_target', :action => 'show')
    assert_routing('/results/excalibur.watson.ibm.com/core.36', :host_name => 'excalibur.watson.ibm.com', :test_run_name => 'core', :test_run_id => '36', :controller => 'results/test_run', :action => 'show')
    assert_routing('/results/excalibur.watson.ibm.com', :host_name => 'excalibur.watson.ibm.com', :controller => 'results/host', :action => 'show')
    assert_routing('/results/hosts', :controller => 'results/host', :action => 'list')
    assert_routing('/admin', :controller => 'admin/dashboard', :action => 'index')
    assert_routing('/admin/sysinfo', :controller => 'admin/sysinfo', :action => 'show')
    assert_routing('/admin/sysinfo/purge_historic_result_facts', :controller => 'admin/sysinfo', :action => 'purge_historic_result_facts')
    assert_routing('/admin/sysinfo/purge_historic_statistic_facts', :controller => 'admin/sysinfo', :action => 'purge_historic_statistic_facts')
    assert_routing('/admin/sysinfo/purge_stale_sessions', :controller => 'admin/sysinfo', :action => 'purge_stale_sessions')
    assert_routing('/security/access_denied', :controller => 'security', :action => 'access_denied')
    assert_routing('/security/administrators', :controller => 'security', :action => 'administrators')
    assert_routing('/security/login', :controller => 'security', :action => 'login')
    assert_routing('/security/logout', :controller => 'security', :action => 'logout')
    assert_routing('/', :controller => 'dashboard', :action => 'index')

    assert_routing('/reports/excalibur.watson.ibm.com/core.36', :host_name => 'excalibur.watson.ibm.com', :test_run_name => 'core', :test_run_id => '36', :controller => 'reports/test_run_by_revision_report', :action => 'show')

    [:show, :enable_admin, :disable_admin, :activate, :deactivate].each do |action|
      assert_routing("/admin/user/#{action}/1", :controller => 'admin/user', :action => action.to_s, :id => '1')
    end

    assert_routing("/admin/user/list", :controller => 'admin/user', :action => 'list')

    assert_routing('/explorer', :controller => 'explorer/dashboard', :action => 'index')
    # The following untested as they are likely to change in future
    # map.connect 'explorer/filter/:action/:id', :controller => 'explorer/filter'
    # map.connect 'explorer/report/:action/:id', :controller => 'explorer/report'
    # map.connect 'explorer/summarizer/:action/:id', :controller => 'explorer/summarizer'
  end
end
