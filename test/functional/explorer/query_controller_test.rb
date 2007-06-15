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
    assert_response(:success)
    assert_template('list')
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])

    assert_not_nil(assigns(:query_pages))
    assert_equal(0, assigns(:query_pages).current.offset)
    assert_equal(1, assigns(:query_pages).page_count)
    assert_equal([1], assigns(:queries).collect {|r| r.id} )
  end

  def test_new_get
    get(:edit, {}, session_data)
    assert_response(:success)
    assert_template('edit')
    assert_not_nil(assigns(:query))
    assert_equal(true, assigns(:query).new_record?)
    assert_nil(flash[:flash])
    assert_nil(flash[:alert])

    assert_standard_edit_assigns
  end

  def assert_standard_edit_assigns
    assert_not_nil(assigns(:filters))
    assert_equal([2, 1], assigns(:filters).collect{|f|f.id})
    assert_not_nil(assigns(:measures))
    assert_equal([5, 3, 2, 4, 1], assigns(:measures).collect{|m|m.id})
  end


  def test_new_post_with_error
    post(:edit, {:query => {:name => '', :description => '', :primary_dimension => 'build_configuration_name', :secondary_dimension => 'time_day_of_week', :measure_id => 1}}, session_data)
    assert_response(:success)
    assert_template('edit')
    assert_not_nil(assigns(:query))
    assert_equal(true, assigns(:query).new_record?)
    assert_not_nil(assigns(:query).errors[:name])
    assert_nil(flash[:flash])
    assert_nil(flash[:alert])
    assert_standard_edit_assigns
  end

  def test_new_post
    post(:edit, {:query => {:name => 'X', :description => '', :primary_dimension => 'build_configuration_name', :secondary_dimension => 'time_day_of_week', :measure_id => 1, :filter_id => 1, :presentation_id => 1}}, session_data)
    assert_redirected_to(:action => 'list')
    assert_not_nil(assigns(:query))
    assert_equal(false, assigns(:query).new_record?)
    assert_equal('build_configuration_name', assigns(:query).primary_dimension)
    assert_equal('time_day_of_week', assigns(:query).secondary_dimension)
    assert_equal(1, assigns(:query).measure_id)
    assert_equal("Query named 'X' was successfully saved.", flash[:notice])
    assert_nil(flash[:alert])
  end

  def test_edit_get
    get(:edit, {:id => 1}, session_data)
    assert_response(:success)
    assert_template('edit')
    assert_not_nil(assigns(:query))
    assert_equal(1, assigns(:query).id)
    assert_nil(flash[:flash])
    assert_nil(flash[:alert])
    assert_standard_edit_assigns
  end

  def test_edit_post_with_error
    post(:edit, {:id => 1, :query => {:name => '', :description => '', :primary_dimension => 'build_configuration_name', :secondary_dimension => 'time_day_of_week', :measure_id => 1}}, session_data)
    assert_response(:success)
    assert_template('edit')
    assert_not_nil(assigns(:query))
    assert_equal(1, assigns(:query).id)
    assert_not_nil(assigns(:query).errors[:name])
    assert_nil(flash[:flash])
    assert_nil(flash[:alert])
    assert_standard_edit_assigns
  end

  def test_edit_post
    post(:edit, {:id => 1, :query => {:name => 'X', :description => '', :primary_dimension => 'build_configuration_name', :secondary_dimension => 'time_day_of_week', :measure_id => 1}}, session_data)
    assert_redirected_to(:action => 'list')
    assert_not_nil(assigns(:query))
    assert_equal(1, assigns(:query).id)
    assert_equal('build_configuration_name', assigns(:query).primary_dimension)
    assert_equal('time_day_of_week', assigns(:query).secondary_dimension)
    assert_equal(1, assigns(:query).measure_id)
    assert_equal("Query named 'X' was successfully saved.", flash[:notice])
    assert_nil(flash[:alert])
  end

  def test_destroy
    id = 1
    assert(Olap::Query::Query.exists?(id))
    post(:destroy, {:id => id}, session_data)
    assert_redirected_to(:action => 'list')
    assert_equal("Query named 'Success Rate by Build Configuration by Day of Week' was successfully deleted.", flash[:notice])
    assert_nil(flash[:alert])
    assert(!Olap::Query::Query.exists?(id))
  end
end