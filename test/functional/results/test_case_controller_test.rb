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
require 'results/test_case_controller'

class Results::TestCaseController
  # Re-raise errors caught by the controller.
  def rescue_action(e)
    raise e
  end
end

class Results::TestCaseControllerTest < Test::Unit::TestCase
  def setup
    @controller = Results::TestCaseController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def session_data
    {:user_id => 1}
  end

  def test_show
    id = 1
    params = gen_params(Tdm::TestCase.find(id))
    get(:show, params, session_data)
    assert_normal_response('show', 1)
    assert_assigned(:record)
    assert_equal(id, assigns(:record).id)
  end

  def test_show_output
    get(:show_output, gen_params(Tdm::TestCase.find(1)), session_data)
    assert_response(:success)
    assert_template(nil)
    assert_equal('text/plain; charset=utf-8',@response.headers['Content-Type'])
    assert_equal('1 times around the merry go round',@response.body)
    assert_assigns_count(0)
    assert_flash_count(0)
  end

  def gen_params(test_case)
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
    params
  end
end
