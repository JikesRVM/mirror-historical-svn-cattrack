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
require 'explorer/report_controller'

class Explorer::ReportController
  # Re-raise errors caught by the controller.
  def rescue_action(e)
    raise e
  end
end

class Explorer::ReportControllerTest < Test::Unit::TestCase
  def setup
    @controller = Explorer::ReportController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def session_data
    {:user_id => 1}
  end

  def test_list
    get(:list, {}, session_data)
    assert_normal_response('list', 20)

    assert_equal(['helm','skunk'], assigns(:host_names) )
    assert_equal(['core'], assigns(:test_run_names) )
    assert_equal(['ia32_linux'], assigns(:build_target_names) )
    assert_equal(['ia32'], assigns(:build_target_arches) )
    assert_equal(['32'], assigns(:build_target_address_sizes) )
    assert_equal(['Linux'], assigns(:build_target_operating_systems) )
  end
end
