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
require File.dirname(__FILE__) + '/../../test_helper'
require 'results/test_case_statistic_controller'

class Results::TestCaseStatisticController
  # Re-raise errors caught by the controller.
  def rescue_action(e)
    raise e
  end
end

class Results::TestCaseStatisticControllerTest < Test::Unit::TestCase
  def setup
    @controller = Results::TestCaseStatisticController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def session_data
    {:user_id => 1}
  end

  def test_show
    test_run = create_test_run_for_perf_tests
    test_case = test_run.build_configurations[0].test_configurations[0].groups[0].test_cases[0]
    test_case.statistics['my_stat'] = '10'
    test_case.save!
    get(:show, gen_params(test_case, 'my_stat'), session_data)
    assert_response(:success)
    assert_template(nil)
    assert_equal('image/png',@response.headers['Content-Type'])
    assert_assigns_count(0)
    assert_flash_count(0)
  end

  def gen_params(test_case, statistic_key)
    group = test_case.group
    test_configuration = group.test_configuration
    build_configuration = test_configuration.build_configuration
    test_run = build_configuration.test_run
    host = test_run.host
    params = {:host_name => host.name}
    params.merge!(:test_run_variant => test_run.variant, :test_run_id => test_run.id)
    params.merge!(:build_configuration_name => build_configuration.name)
    params.merge!(:test_configuration_name => test_configuration.name)
    params.merge!(:group_name => group.name)
    params.merge!(:test_case_name => test_case.name)
    params.merge!(:statistic_key => statistic_key)
    params
  end
end
