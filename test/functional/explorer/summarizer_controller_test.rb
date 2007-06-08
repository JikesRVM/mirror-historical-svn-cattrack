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
require 'explorer/summarizer_controller'

class Explorer::SummarizerController
  # Re-raise errors caught by the controller.
  def rescue_action(e)
    raise e
  end
end

class Explorer::SummarizerControllerTest < Test::Unit::TestCase
  def setup
    @controller = Explorer::SummarizerController.new
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

    assert_not_nil(assigns(:summarizer_pages))
    assert_equal(0, assigns(:summarizer_pages).current.offset)
    assert_equal(1, assigns(:summarizer_pages).page_count)
    assert_equal([1], assigns(:summarizers).collect {|r| r.id} )
  end

  def test_new_get
    get(:edit, {}, session_data)
    assert_response(:success)
    assert_template('edit')
    assert_not_nil(assigns(:summarizer))
    assert_equal(true, assigns(:summarizer).new_record?)
    assert_nil(flash[:flash])
    assert_nil(flash[:alert])
  end

  def test_new_post_with_error
    post(:edit, {:summarizer => {:name => '', :description => '', :primary_dimension => 'build_configuration_name', :secondary_dimension => 'time_day_of_week', :function => 'success_rate'}}, session_data)
    assert_response(:success)
    assert_template('edit')
    assert_not_nil(assigns(:summarizer))
    assert_equal(true, assigns(:summarizer).new_record?)
    assert_not_nil(assigns(:summarizer).errors[:name])
    assert_nil(flash[:flash])
    assert_nil(flash[:alert])
  end

  def test_new_post
    post(:edit, {:summarizer => {:name => 'X', :description => '', :primary_dimension => 'build_configuration_name', :secondary_dimension => 'time_day_of_week', :function => 'success_rate'}}, session_data)
    assert_redirected_to(:action => 'list')
    assert_not_nil(assigns(:summarizer))
    assert_equal(false, assigns(:summarizer).new_record?)
    assert_equal('build_configuration_name', assigns(:summarizer).primary_dimension)
    assert_equal('time_day_of_week', assigns(:summarizer).secondary_dimension)
    assert_equal('success_rate', assigns(:summarizer).function)
    assert_equal("Summarizer named 'X' was successfully saved.", flash[:notice])
    assert_nil(flash[:alert])
  end

  def test_edit_get
    get(:edit, {:id => 1}, session_data)
    assert_response(:success)
    assert_template('edit')
    assert_not_nil(assigns(:summarizer))
    assert_equal(1, assigns(:summarizer).id)
    assert_nil(flash[:flash])
    assert_nil(flash[:alert])
  end

  def test_edit_post_with_error
    post(:edit, {:id => 1, :summarizer => {:name => '', :description => '', :primary_dimension => 'build_configuration_name', :secondary_dimension => 'time_day_of_week', :function => 'success_rate'}}, session_data)
    assert_response(:success)
    assert_template('edit')
    assert_not_nil(assigns(:summarizer))
    assert_equal(1, assigns(:summarizer).id)
    assert_not_nil(assigns(:summarizer).errors[:name])
    assert_nil(flash[:flash])
    assert_nil(flash[:alert])
  end

  def test_edit_post
    post(:edit, {:id => 1, :summarizer => {:name => 'X', :description => '', :primary_dimension => 'build_configuration_name', :secondary_dimension => 'time_day_of_week', :function => 'success_rate'}}, session_data)
    assert_redirected_to(:action => 'list')
    assert_not_nil(assigns(:summarizer))
    assert_equal(1, assigns(:summarizer).id)
    assert_equal('build_configuration_name', assigns(:summarizer).primary_dimension)
    assert_equal('time_day_of_week', assigns(:summarizer).secondary_dimension)
    assert_equal('success_rate', assigns(:summarizer).function)
    assert_equal("Summarizer named 'X' was successfully saved.", flash[:notice])
    assert_nil(flash[:alert])
  end

  def test_destroy
    id = 1
    assert(Summarizer.exists?(id))
    post(:destroy, {:id => id}, session_data)
    assert_redirected_to(:action => 'list')
    assert_equal("Summarizer named 'Success Rate by Build Configuration by Day of Week' was successfully deleted.", flash[:notice])
    assert_nil(flash[:alert])
    assert(!Summarizer.exists?(id))
  end
end
