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
require 'explorer/base_controller'

class Explorer::BaseController
  def raise_error
    raise AuthenticatedSystem::SecurityError
  end
end

class Explorer::BaseControllerTest < Test::Unit::TestCase
  def setup
    @controller = Explorer::BaseController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_access_denied_with_unauthenticated
    get(:raise_error, {}, {})
    assert_response(403)
    assert_template('login_required')
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end
end
