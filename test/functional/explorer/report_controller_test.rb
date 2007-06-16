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
require 'explorer/report_controller'

class Explorer::ReportController
  # Re-raise errors caught by the controller.
  def rescue_action(e)
    raise e
  end
end

class Explorer::ReportControllerTest < Test::Unit::TestCase
  def setup
    @controller = Explorer::ReportController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def session_data
    {:user_id => 1}
  end

  def test_public_list
    get(:public_list, {}, session_data)
    assert_response(:success)
    assert_normal_response('public_list', 2)
    assert_assigned(:report_pages)
    assert_assigned(:reports)

    assert_equal([1], assigns(:reports).collect {|r| r.id} )
    assert_equal(0, assigns(:report_pages).current.offset)
    assert_equal(1, assigns(:report_pages).page_count)
  end

  def test_show_missing_key
    assert_raises(CatTrack::SecurityError) {get(:show, {:key => 'X'}, session_data)}
  end

  def test_show
    get(:show, {:key => 'SRxBNxW'}, session_data)
    assert_response(:success)
    assert_normal_response('show', 2)
    assert_assigned(:report)
    assert_assigned(:results)
    assert_equal(1, assigns(:report).id)
  end

  def test_list
    get(:list, {}, session_data)
    assert_response(:success)
    assert_normal_response('list', 2)
    assert_assigned(:report_pages)
    assert_assigned(:reports)

    assert_equal([1], assigns(:reports).collect {|r| r.id} )
    assert_equal(0, assigns(:report_pages).current.offset)
    assert_equal(1, assigns(:report_pages).page_count)
  end

  def assert_standard_edit_assigns
    assert_assigned(:presentations)
    assert_assigned(:queries)
    assert_assigned(:report)
    assert_equal([1, 3, 2], assigns(:presentations).collect {|r| r.id} )
    assert_equal([1], assigns(:queries).collect {|r| r.id} )
  end

  def test_new_get
    get(:new, {}, session_data)
    assert_normal_response('new', 1 + 2)
    assert_standard_edit_assigns
    assert_new_record(:report)
  end

  def test_new_post_with_error
    post(:new, {:report => {:name => '', :description => '', :query_id => 1, :presentation_id => 1}}, session_data)
    assert_normal_response('new', 1 + 2)
    assert_standard_edit_assigns
    assert_new_record(:report)
    assert_error_on(:report, :name)
  end

  def test_new_post
    post(:new, {:report => {:name => 'X', :description => '', :query_id => 1, :presentation_id => 1, :key => 'x'}}, session_data)
    assert_redirected_to(:action => 'list')
    assert_assigns_count(1)
    assert_flash_count(1)
    assert_assigned(:report)
    assert_equal(false, assigns(:report).new_record?)
    assert_equal(1, assigns(:report).query_id)
    assert_equal(1, assigns(:report).presentation_id)
    assert_equal('x', assigns(:report).key)
    assert_flash(:notice, "Report named 'X' was successfully created.")
  end

  def test_edit_get
    get(:edit, {:id => 1}, session_data)
    assert_response(:success)
    assert_normal_response('edit', 1 + 2)
    assert_standard_edit_assigns
    assert_equal(1, assigns(:report).id)
  end

  def test_edit_post_with_error
    post(:edit, {:id => 1, :report => {:name => '', :description => '', :query_id => 1, :presentation_id => 1}}, session_data)
    assert_normal_response('edit', 1 + 2)
    assert_standard_edit_assigns
    assert_equal(1, assigns(:report).id)
    assert_error_on(:report, :name)
  end

  def test_edit_post
    post(:edit, {:id => 1, :report => {:name => 'X', :description => '', :query_id => 1, :presentation_id => 1}}, session_data)
    assert_redirected_to(:action => 'list')
    assert_assigns_count(1)
    assert_flash_count(1)
    assert_assigned(:report)
    assert_equal(1, assigns(:report).id)
    assert_equal(1, assigns(:report).query_id)
    assert_equal(1, assigns(:report).presentation_id)
    assert_flash(:notice, "Report named 'X' was successfully saved.")
  end

  def test_destroy
    id = 1
    assert(Olap::Query::Report.exists?(id))
    post(:destroy, {:id => id}, session_data)
    assert_redirected_to(:action => 'list')
    assert_assigns_count(0)
    assert_flash_count(1)
    assert_flash(:notice, "Report named 'Success Rate by Build Configuration by Day of Week Report' was successfully deleted.")
    assert(!Olap::Query::Report.exists?(id))
  end
end
