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
require 'explorer/query_controller'

class Explorer::QueryController
  # Re-raise errors caught by the controller.
  def rescue_action(e)
    raise e
  end
end

class Explorer::QueryControllerTest < Test::Unit::TestCase
  def setup
    @controller = Explorer::QueryController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def session_data
    {:user_id => 1}
  end

  def test_list
    get(:list, {}, session_data)
    assert_normal_response('list', 2)
    assert_assigned(:query_pages)
    assert_assigned(:queries)
    assert_equal(0, assigns(:query_pages).current.offset)
    assert_equal(1, assigns(:query_pages).page_count)
    assert_equal([1], assigns(:queries).collect {|r| r.id} )
  end

  def assert_standard_edit_assigns
    assert_assigned(:query)
    assert_assigned(:filters)
    assert_equal([2, 1], assigns(:filters).collect{|f|f.id})
    assert_assigned(:measures)
    assert_equal([5, 3, 2, 4, 1], assigns(:measures).collect{|m|m.id})
  end

  def test_new_get
    get(:new, {}, session_data)
    assert_normal_response('new', 3)
    assert_standard_edit_assigns
    assert_new_record(:query)
  end

  def test_new_post_with_error
    post(:new, {:query => {:name => '', :description => '', :primary_dimension => 'build_configuration_name', :secondary_dimension => 'time_day_of_week', :measure_id => 1}}, session_data)
    assert_normal_response('new', 3)
    assert_standard_edit_assigns
    assert_new_record(:query)
    assert_error_on(:query, :name)
  end

  def test_new_post
    post(:new, {:query => {:name => 'X', :description => '', :primary_dimension => 'build_configuration_name', :secondary_dimension => 'time_day_of_week', :measure_id => 1, :filter_id => 1}}, session_data)
    assert_redirected_to(:action => 'list')
    assert_assigns_count(1)
    assert_flash_count(1)
    assert_not_nil(assigns(:query))
    assert_equal(false, assigns(:query).new_record?)
    assert_equal('build_configuration_name', assigns(:query).primary_dimension)
    assert_equal('time_day_of_week', assigns(:query).secondary_dimension)
    assert_equal(1, assigns(:query).measure_id)
    assert_flash(:notice, "Query named 'X' was successfully created.")
  end

  def test_edit_get
    get(:edit, {:id => 1}, session_data)
    assert_normal_response('edit', 3)
    assert_standard_edit_assigns
    assert_equal(1, assigns(:query).id)
  end

  def test_edit_post_with_error
    post(:edit, {:id => 1, :query => {:name => '', :description => '', :primary_dimension => 'build_configuration_name', :secondary_dimension => 'time_day_of_week', :measure_id => 1}}, session_data)
    assert_normal_response('edit', 3)
    assert_standard_edit_assigns
    assert_equal(1, assigns(:query).id)
    assert_error_on(:query, :name)
  end

  def test_edit_post
    post(:edit, {:id => 1, :query => {:name => 'X', :description => '', :primary_dimension => 'build_configuration_name', :secondary_dimension => 'time_day_of_week', :measure_id => 1}}, session_data)
    assert_redirected_to(:action => 'list')
    assert_assigns_count(1)
    assert_flash_count(1)
    assert_not_nil(assigns(:query))
    assert_equal(1, assigns(:query).id)
    assert_equal('build_configuration_name', assigns(:query).primary_dimension)
    assert_equal('time_day_of_week', assigns(:query).secondary_dimension)
    assert_equal(1, assigns(:query).measure_id)
    assert_flash(:notice, "Query named 'X' was successfully saved.")
  end

  def test_destroy
    id = 1
    assert(Olap::Query::Query.exists?(id))
    post(:destroy, {:id => id}, session_data)
    assert_redirected_to(:action => 'list')
    assert_assigns_count(0)
    assert_flash_count(1)
    assert_flash(:notice, "Query named 'Success Rate by Build Configuration by Day of Week' was successfully deleted.")
    assert(!Olap::Query::Query.exists?(id))
  end
end
