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
require 'admin/base_controller'

class Admin::BaseController
  def index
    render :text => '', :layout => false
  end
end

class Admin::BaseControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::BaseController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  self.auto_validate_excludes = [:test_allow_access_to_admin]

  def test_allow_access_to_admin
    get(:index, {}, {:user_id => 1})
    assert_response(:success)
    assert_flash_count(0)
  end

  def test_deny_access_to_non_admin
    get(:index, {}, {:user_id => 2})
    assert_normal_response('access_denied', 0, 0, 403)
  end
end
