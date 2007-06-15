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
    assert_normal_response('show', 1)
    assert_assigned(:orhpan_dimensions)    
  end

  def test_purge_stale_sessions
    time = Time.at(0)
    CGI::Session::ActiveRecordStore::Session.create!( :sessid => 'abcde', :data => '', :created_on => time, :updated_on => time )
    assert_equal(1, CGI::Session::ActiveRecordStore::Session.count)
    post(:purge_stale_sessions, {}, {:user_id => 1})
    assert_redirected_to(:action => 'show')
    assert_flash_count(0)
    assert_assigns_count(0)
    assert_equal(0, CGI::Session::ActiveRecordStore::Session.count)
  end

  def test_purge_historic_result_facts
    assert_equal([1, 2], Olap::ResultFact.find(:all, :order => 'id').collect{|r|r.id})
    post(:purge_historic_result_facts, {}, {:user_id => 1})
    assert_redirected_to(:action => 'show')
    assert_flash_count(0)
    assert_assigns_count(0)
    assert_equal([1], Olap::ResultFact.find(:all, :order => 'id').collect{|r|r.id})
  end

  def test_purge_historic_statistic_facts
    assert_equal([1, 2], Olap::StatisticFact.find(:all, :order => 'id').collect{|r|r.id})
    post(:purge_historic_statistic_facts, {}, {:user_id => 1})
    assert_redirected_to(:action => 'show')
    assert_flash_count(0)
    assert_assigns_count(0)
    assert_equal([1], Olap::StatisticFact.find(:all, :order => 'id').collect{|r|r.id})
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
    ["Result", 2, Olap::ResultDimension],
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
