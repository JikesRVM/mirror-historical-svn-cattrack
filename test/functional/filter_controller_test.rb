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
require 'filter_controller'

class FilterController
  # Re-raise errors caught by the controller.
  def rescue_action(e)
    raise e
  end
end

class FilterControllerTest < Test::Unit::TestCase

  def setup
    @controller = FilterController.new
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

    assert_not_nil(assigns(:filter_pages))
    assert_equal(0, assigns(:filter_pages).current.offset)
    assert_equal(1, assigns(:filter_pages).page_count)
    assert_equal([2, 1], assigns(:filters).collect {|r| r.id} )
  end

  def test_new_get
    get(:edit, {}, session_data)
    assert_response(:success)
    assert_template('edit')
    assert_not_nil(assigns(:filter))
    assert_equal(true, assigns(:filter).new_record?)
  end

  def test_new_post_with_error
    post(:edit, {:filter => {:name => '', :description => '', :revision_after => '123'}}, session_data)
    assert_response(:success)
    assert_template('edit')
    assert_not_nil(assigns(:filter))
    assert_equal(true, assigns(:filter).new_record?)
    assert_not_nil(assigns(:filter).errors[:name])
  end

  def test_new_post
    post(:edit, {:filter => {:name => 'X', :description => '', :revision_after => '123'}}, session_data)
    assert_redirected_to(:action => 'list')
    assert_not_nil(assigns(:filter))
    assert_equal(false, assigns(:filter).new_record?)
    assert_equal('123', assigns(:filter).revision_after)
  end

  def test_edit_get
    get(:edit, {:id => 1}, session_data)
    assert_response(:success)
    assert_template('edit')
    assert_not_nil(assigns(:filter))
    assert_equal(1, assigns(:filter).id)
  end

  def test_edit_post_with_error
    post(:edit, {:id => 1, :filter => {:name => '', :description => '', :revision_after => '123'}}, session_data)
    assert_response(:success)
    assert_template('edit')
    assert_not_nil(assigns(:filter))
    assert_equal(1, assigns(:filter).id)
    assert_not_nil(assigns(:filter).errors[:name])
  end

  def test_edit_post
    post(:edit, {:id => 1, :filter => {:name => 'X', :description => '', :revision_after => '123'}}, session_data)
    assert_redirected_to(:action => 'list')
    assert_not_nil(assigns(:filter))
    assert_equal(1, assigns(:filter).id)
    assert_equal('123', assigns(:filter).revision_after)
  end

=begin
  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:filter)
    assert assigns(:filter).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end
=end

  def test_destroy
    id = 1
    assert(Filter.exists?(id))
    post(:destroy, {:id => id}, session_data)
    assert_redirected_to(:action => 'list')
    assert_equal("Filter named 'Last Week' was successfully deleted.", flash[:notice])
    assert(!Filter.exists?(id))
  end
end
