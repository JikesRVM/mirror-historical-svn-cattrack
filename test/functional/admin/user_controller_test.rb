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
require 'admin/user_controller'

class Admin::UserController
  # Re-raise errors caught by the controller.
  def rescue_action(e)
    raise e
  end
end

class Admin::UserControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::UserController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def session_data
    {:user_id => 1}
  end

  def test_show
    id = 1
    get(:show, {:id => id}, session_data)
    assert_normal_response('show', 1)
    assert_assigned(:record)
    assert_equal(id, assigns(:record).id)
  end

  def test_list
    get(:list, {}, session_data)
    assert_normal_response('list', 2)
    assert_assigned(:records)
    assert_assigned(:record_pages)

    assert_equal([4, 3, 1, 2, 5], assigns(:records).collect {|r| r.id} )
    assert_equal(0, assigns(:record_pages).current.offset)
    assert_equal(1, assigns(:record_pages).page_count)
  end

  def test_list_with_query
    get(:list, {:q => 'e'}, session_data)
    assert_normal_response('list', 2)
    assert_assigned(:records)
    assert_assigned(:record_pages)

    assert_equal([4, 3, 1], assigns(:records).collect {|r| r.id} )
    assert_equal(0, assigns(:record_pages).current.offset)
    assert_equal(1, assigns(:record_pages).page_count)
  end

  def test_destroy
    id = 4
    assert(User.exists?(id))
    label = User.find(id).label
    post(:destroy, {:id => id}, session_data)
    assert_redirected_to(:action => 'list')
    assert_assigns_count(0)
    assert_flash_count(1)
    assert(!User.exists?(id))
    assert_flash(:notice, "#{label} was successfully deleted.")
  end

  def test_enable_admin
    assert(!User.find(2).admin?)
    post(:enable_admin, {:id => 2}, session_data)
    assert_redirected_to(:action => 'show', :id => 2)
    assert_assigns_count(0)
    assert_flash_count(0)
    assert(User.find(2).admin?)
  end

  def test_disable_admin
    assert(User.find(1).admin?)
    post(:disable_admin, {:id => 1}, session_data)
    assert_redirected_to(:action => 'show', :id => 1)
    assert_assigns_count(0)
    assert_flash_count(0)
    assert(!User.find(1).admin?)
  end

  def test_activate
    id = 4
    assert(!User.find(id).active?)
    post(:activate, {:id => id}, session_data)
    assert_redirected_to(:action => 'show', :id => id)
    assert_assigns_count(0)
    assert_flash_count(0)
    assert(User.find(id).active?)
  end

  def test_deactivate
    id = 1
    assert(User.find(id).active?)
    post(:deactivate, {:id => id}, session_data)
    assert_redirected_to(:action => 'show', :id => id)
    assert_assigns_count(0)
    assert_flash_count(0)
    assert(!User.find(id).active?)
  end
end
