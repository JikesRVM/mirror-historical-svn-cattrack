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
require 'results/test_run_controller'

class Results::TestRunController
  # Re-raise errors caught by the controller.
  def rescue_action(e)
    raise e
  end
end

class Results::TestRunControllerTest < Test::Unit::TestCase
  def setup
    @controller = Results::TestRunController.new
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
    assert_assigned(:record)
    assert_equal(id, assigns(:record).id)
  end

  def test_show_summary
    id = 1
    test_run = Tdm::TestRun.find(id)
    get(:show_summary, {:host_name => test_run.host.name, :test_run_name => test_run.name, :test_run_id => test_run.id}, session_data)
    assert_normal_response('show_summary', 1)
    assert_assigned(:record)
    assert_equal(id, assigns(:record).id)
  end

  def test_destroy
    id = 1
    assert(Tdm::TestRun.exists?(id))
    test_run = Tdm::TestRun.find(id)
    label = test_run.label
    host_name = test_run.host.name
    purge_log

    path = File.expand_path("#{RAILS_ROOT}/public/results/skunk/core.1")
    file = "#{path}.html"
    FileUtils.mkdir_p(path)
    f = File.new(file,  "w+")
    f.write('hi')
    f.close
    assert(File.exists?(path))
    assert(File.exists?(file))

    delete(:destroy, {:host_name => host_name, :test_run_name => test_run.name, :test_run_id => test_run.id}, session_data)
    assert_redirected_to(:controller => 'results/host', :action => 'show', :host_name => host_name)
    assert(!Tdm::TestRun.exists?(id))
    assert_assigned(:record)
    assert_equal(id, assigns(:record).id)
    assert_equal(true, assigns(:record).frozen?)
    assert_flash_count(1)
    assert_equal("#{label} was successfully deleted.", flash[:notice])
    assert_logs([["test-run.deleted", 'id=1 (core-1)']], 1)
    assert(!File.exists?(path))
    assert(!File.exists?(file))
  end
end
