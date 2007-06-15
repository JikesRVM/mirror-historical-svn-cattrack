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
require 'reports/test_run_by_revision_report_controller'

class Reports::TestRunByRevisionReportController
  # Re-raise errors caught by the controller.
  def rescue_action(e)
    raise e
  end
end

class Reports::TestRunByRevisionReportControllerTest < Test::Unit::TestCase
  def setup
    @controller = Reports::TestRunByRevisionReportController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def session_data
    {:user_id => 1}
  end

  def test_show
    id = 1
    test_run = Tdm::TestRun.find(id)
    get(:show, {:host_name => test_run.host.name, :test_run_name => test_run.name, :test_run_id => test_run.id}, session_data)
    assert_normal_response('show', 1)
    assert_assigned(:report)
    assert_equal(id, assigns(:report).test_run.id)
  end
end
