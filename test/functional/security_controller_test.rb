#
#  This file is part of the Jikes RVM project (http://jikesrvm.org).
#
#  This file is licensed to You under the Eclipse Public License (EPL);
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
    assert_normal_response('login')
  end

  def test_login_post_success
    post(:login, {:username => 'peter', :password => 'retep'}, {})
    assert_redirected_to(:controller => 'dashboard')
    assert_flash_count(0)
  end

  def test_login_post_fail
    post(:login, {:username => 'peter', :password => ''}, {})
    assert_normal_response('login', 0, 1)
    assert_flash(:alert, 'Incorrect Login or Password.')
  end

  def test_logout
    post(:logout, {}, {:user_id => User.find(1).id})
    assert_redirected_to(:action => 'login')
    assert_flash_count(1)
    assert_flash(:notice, 'You have been logged out.')
  end

  def test_administrators
    get(:administrators, {}, {})
    assert_normal_response('administrators')
  end

  def test_access_denied
    get(:access_denied, {}, {})
    assert_normal_response('access_denied', 0, 0, 403)
  end
end
