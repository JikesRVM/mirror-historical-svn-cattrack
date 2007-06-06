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
    assert_response(:success)
    assert_template('show')
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_purge_stale_sessions
    time = Time.at(0)
    CGI::Session::ActiveRecordStore::Session.create!( :sessid => 'abcde', :data => '', :created_on => time, :updated_on => time )
    assert_equal(1, CGI::Session::ActiveRecordStore::Session.count)
    post(:purge_stale_sessions, {}, {:user_id => 1})
    assert_redirected_to(:action => 'show')
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
    assert_equal(0, CGI::Session::ActiveRecordStore::Session.count)
  end

  def test_purge_historic_result_facts
    assert_equal([1, 2], ResultFact.find(:all, :order => 'id').collect{|r|r.id})
    post(:purge_historic_result_facts, {}, {:user_id => 1})
    assert_redirected_to(:action => 'show')
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
    assert_equal([1], ResultFact.find(:all, :order => 'id').collect{|r|r.id})
  end

  def test_purge_historic_statistic_facts
    assert_equal([1, 2], StatisticFact.find(:all, :order => 'id').collect{|r|r.id})
    post(:purge_historic_statistic_facts, {}, {:user_id => 1})
    assert_redirected_to(:action => 'show')
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
    assert_equal([1], StatisticFact.find(:all, :order => 'id').collect{|r|r.id})
  end

  def test_purge_orphan_dimensions
    assert_equal(
    [
    ["Host", 2, HostDimension],
    ["TestRun", 0, TestRunDimension],
    ["TestConfiguration", 6, TestConfigurationDimension],
    ["BuildConfiguration", 4, BuildConfigurationDimension],
    ["BuildTarget", 0, BuildTargetDimension],
    ["TestCase", 2, TestCaseDimension],
    ["Time", 2, TimeDimension],
    ["Revision", 2, RevisionDimension],
    ["Result", 2, ResultDimension],
    ["Statistic", 0, StatisticDimension],
    ],
    @controller.send(:dimension_data))
    post(:purge_orphan_dimensions, {}, {:user_id => 1})
    assert_redirected_to(:action => 'show')
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
    assert_equal(
    [
    ["Host", 0, HostDimension],
    ["TestRun", 0, TestRunDimension],
    ["TestConfiguration", 0, TestConfigurationDimension],
    ["BuildConfiguration", 0, BuildConfigurationDimension],
    ["BuildTarget", 0, BuildTargetDimension],
    ["TestCase", 0, TestCaseDimension],
    ["Time", 0, TimeDimension],
    ["Revision", 0, RevisionDimension],
    ["Result", 0, ResultDimension],
    ["Statistic", 0, StatisticDimension]
    ],
    @controller.send(:dimension_data))
  end
end
