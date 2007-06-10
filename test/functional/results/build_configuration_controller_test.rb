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
require 'results/build_configuration_controller'

class Results::BuildConfigurationController
  # Re-raise errors caught by the controller.
  def rescue_action(e)
    raise e
  end
end

class Results::BuildConfigurationControllerTest < Test::Unit::TestCase
  def setup
    @controller = Results::BuildConfigurationController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def session_data
    {:user_id => 1}
  end

  def test_show
    id = 1
    build_configuration = BuildConfiguration.find(id)
    test_run = build_configuration.test_run
    host = test_run.host
    params = {:host_name => host.name}
    params.merge!(:test_run_name => test_run.name, :test_run_id => test_run.id)
    params.merge!(:build_configuration_name => build_configuration.name)

    get(:show, params, session_data)
    assert_response(:success)
    assert_template('show')
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
    assert_not_nil(assigns(:record))
    assert_equal(1, assigns(:record).id)
  end

  def test_show_output
    id = 1
    build_configuration = BuildConfiguration.find(id)
    test_run = build_configuration.test_run
    host = test_run.host
    params = {:host_name => host.name}
    params.merge!(:test_run_name => test_run.name, :test_run_id => test_run.id)
    params.merge!(:build_configuration_name => build_configuration.name)

    get(:show_output, params, session_data)
    assert_response(:success)
    assert_template(nil)
    assert_equal('text/plain; charset=utf-8', @response.headers['Content-Type'])
    assert_equal('Prototype build log here ...', @response.body)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end
end
