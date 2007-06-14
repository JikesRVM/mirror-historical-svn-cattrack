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
require 'dashboard_controller'

class DashboardController
  # Re-raise errors caught by the controller.
  def rescue_action(e)
    raise e
  end
end

class DashboardControllerTest < Test::Unit::TestCase
  def setup
    @controller = DashboardController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    test_run = Tdm::TestRun.new
    test_run.attributes = Tdm::TestRun.find(1).attributes
    test_run.occurred_at = Time.now
    test_run.save!

    get(:index, {}, {:user_id => 1})
    assert_response(:success)
    assert_template('index')
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])

    assert_equal([test_run.id, 2, 1], assigns(:test_runs).collect {|r| r.id} )
    assert_not_nil(assigns(:test_run_pages))
    assert_equal(0, assigns(:test_run_pages).current.offset)
    assert_equal(1, assigns(:test_run_pages).page_count)
  end
end
