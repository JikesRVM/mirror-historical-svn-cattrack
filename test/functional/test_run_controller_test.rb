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
require 'test_run_controller'

class TestRunController
  # Re-raise errors caught by the controller.
  def rescue_action(e)
    raise e
  end
end

class TestRunControllerTest < Test::Unit::TestCase
  def setup
    @controller = TestRunController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def model
    TestRun
  end

  def session_data
    {:user_id => 1}
  end

  def test_new_get
    get(:new, {}, session_data)
    assert_response(:success)
    assert_template('new')
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
    assert_not_nil(assigns(:record))
  end

  def test_new_post_with_errors
    post(:new, {:record => {:host => 'foo'}}, session_data)
    assert_response(:success)
    assert_template('new')
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
    assert_not_nil(assigns(:record))

    assert_not_nil(assigns(:record).errors[:data])
  end

  def test_new_post
    post(:new, {:record => {:host => 'foo', :data => fixture_file_upload('/data/Report.xml', 'text/xml')}}, session_data)
    assert_not_nil(assigns(:record))
    assert_not_nil(assigns(:test_run))
    assert_redirected_to(:controller => 'test_run', :action => 'show', :id => assigns(:test_run).id)
    assert_equal("#{assigns(:test_run).label} was successfully created.", flash[:notice])
    assert_nil(flash[:alert])
    assert_equal(1, assigns(:test_run).uploader_id)
  end

  def test_show
    id = 1
    get(:show, {:id => id}, session_data)
    assert_response(:success)
    assert_template('show')
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
    assert_not_nil(assigns(:record))
    assert_equal(id, assigns(:record).id)
  end

  def test_show_summary
    id = 1
    get(:show_summary, {:id => id}, session_data)
    assert_response(:success)
    assert_template('show_summary')
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
    assert_not_nil(assigns(:record))
    assert_equal(id, assigns(:record).id)
  end

  def test_destroy
    id = 1
    assert(model.exists?(id))
    label = model.find(id).label
    post(:destroy, {:id => id}, session_data)
    assert_redirected_to(:controller => 'host', :action => 'show', :id => 1)
    assert(!model.exists?(id))
    assert_not_nil(assigns(:record))
    assert_equal(id, assigns(:record).id)
    assert_equal(true, assigns(:record).frozen?)
    assert_equal("#{label} was successfully deleted.", flash[:notice])
    assert_nil(flash[:alert])
  end
end
