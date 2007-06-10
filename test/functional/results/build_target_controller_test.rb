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
require 'results/build_target_controller'

class Results::BuildTargetController
  # Re-raise errors caught by the controller.
  def rescue_action(e)
    raise e
  end
end

class Results::BuildTargetControllerTest < Test::Unit::TestCase
  def setup
    @controller = Results::BuildTargetController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def session_data
    {:user_id => 1}
  end

  def test_show
    id = 1
    build_target = BuildTarget.find(id)
    test_run = build_target.test_run
    host = test_run.host
    params = {:host_name => host.name}
    params.merge!(:test_run_name => test_run.name, :test_run_id => test_run.id)

    get(:show, params, session_data)
    assert_response(:success)
    assert_template('show')
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
    assert_not_nil(assigns(:record))
    assert_equal(id, assigns(:record).id)
  end
end
