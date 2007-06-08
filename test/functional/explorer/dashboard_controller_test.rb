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
require 'explorer/dashboard_controller'

class Explorer::DashboardController
  # Re-raise errors caught by the controller.
  def rescue_action(e)
    raise e
  end
end

class Explorer::DashboardControllerTest < Test::Unit::TestCase
  def setup
    @controller = Explorer::DashboardController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get(:index, {}, {:user_id => 1})
    assert_response(:success)
    assert_template('index')
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end
end
