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
require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/sysinfo_controller'

class Admin::SysinfoController
  # Re-raise errors caught by the controller.
  def rescue_action(e)
    raise e
  end
end

class Admin::SysinfoControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::SysinfoController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_show
    get(:show, {}, {:user_id => 1})
    assert_normal_response('show')
  end

  def test_show_report_data
    get(:show_report_data, {}, {:user_id => 1})
    assert_normal_response('show_report_data', 1)
    assert_assigned(:orhpan_dimensions)
  end

  def test_purge_stale_sessions
    # Need to specify sql otherwise rails overides updated_on
    sql = <<SQL
    INSERT INTO sessions ("created_on", "updated_on", "sessid", "data") VALUES('1970-01-01 10:00:00.000000', '1970-01-01 10:00:00.000000', 'abcde', '')
SQL
    ActiveRecord::Base.connection.execute(sql)
    assert_equal(1, CGI::Session::ActiveRecordStore::Session.count)
    purge_log
    post(:purge_stale_sessions, {}, {:user_id => 1})
    assert_redirected_to(:action => 'show')
    assert_flash_count(0)
    assert_assigns_count(0)
    assert_equal(0, CGI::Session::ActiveRecordStore::Session.count)
    assert_logs([["sys.purge_stale_sessions", '']], 1)
  end

  def test_purge_historic_result_facts
    assert_equal([1, 2], Olap::ResultFact.find(:all, :order => 'id').collect{|r|r.id})
    purge_log
    post(:purge_historic_result_facts, {}, {:user_id => 1})
    assert_redirected_to(:action => 'show')
    assert_flash_count(0)
    assert_assigns_count(0)
    assert_equal([1], Olap::ResultFact.find(:all, :order => 'id').collect{|r|r.id})
    assert_logs([["sys.purge_historic_result_facts", '']], 1)
  end

  def test_purge_historic_statistic_facts
    assert_equal([1, 2], Olap::StatisticFact.find(:all, :order => 'id').collect{|r|r.id})
    purge_log
    post(:purge_historic_statistic_facts, {}, {:user_id => 1})
    assert_redirected_to(:action => 'show')
    assert_flash_count(0)
    assert_assigns_count(0)
    assert_equal([1], Olap::StatisticFact.find(:all, :order => 'id').collect{|r|r.id})
    assert_logs([["sys.purge_historic_statistic_facts", '']], 1)
  end

  def test_purge_orphan_dimensions
    assert_equal(
    [
    ["Host", 2, Olap::HostDimension],
    ["TestRun", 0, Olap::TestRunDimension],
    ["TestConfiguration", 6, Olap::TestConfigurationDimension],
    ["BuildConfiguration", 4, Olap::BuildConfigurationDimension],
    ["BuildTarget", 0, Olap::BuildTargetDimension],
    ["TestCase", 2, Olap::TestCaseDimension],
    ["Time", 2, Olap::TimeDimension],
    ["Revision", 2, Olap::RevisionDimension],
    ["Result", 1, Olap::ResultDimension],
    ["Statistic", 0, Olap::StatisticDimension],
    ],
    @controller.send(:dimension_data))
    post(:purge_orphan_dimensions, {}, {:user_id => 1})
    assert_redirected_to(:action => 'show')
    assert_flash_count(0)
    assert_assigns_count(0)
    assert_equal(
    [
    ["Host", 0, Olap::HostDimension],
    ["TestRun", 0, Olap::TestRunDimension],
    ["TestConfiguration", 0, Olap::TestConfigurationDimension],
    ["BuildConfiguration", 0, Olap::BuildConfigurationDimension],
    ["BuildTarget", 0, Olap::BuildTargetDimension],
    ["TestCase", 0, Olap::TestCaseDimension],
    ["Time", 0, Olap::TimeDimension],
    ["Revision", 0, Olap::RevisionDimension],
    ["Result", 0, Olap::ResultDimension],
    ["Statistic", 0, Olap::StatisticDimension]
    ],
    @controller.send(:dimension_data))
  end
end
