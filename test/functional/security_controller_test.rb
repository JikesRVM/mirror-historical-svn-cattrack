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
require 'security_controller'

# Re-raise errors caught by the controller.
class SecurityController
  def rescue_action(e)
    raise e
  end
end

class SecurityControllerTest < Test::Unit::TestCase
  def setup
    @controller = SecurityController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_login_get
    get(:login, {}, {})
    assert_response(:success)
    assert_template('login')
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_login_post_success
    post(:login, {:username => 'peter', :password => 'retep'}, {})
    assert_redirected_to(:controller => 'dashboard')
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_login_post_fail
    post(:login, {:username => 'peter', :password => ''}, {})
    assert_response(:success)
    assert_template('login')
    assert_equal('Incorrect Login or Password.', flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_logout
    post(:logout, {}, {:user_id => users(:user_peter).id})
    assert_redirected_to(:action => 'login')
    assert_nil(flash[:alert])
    assert_equal('You have been logged out.', flash[:notice])
  end

  def test_administrators
    get(:administrators, {}, {})
    assert_response(:success)
    assert_template('administrators')
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end
end
