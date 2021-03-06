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

  def test_list_by_variant
    get(:list_by_variant, {:host_name => Tdm::Host.find(1).name, :test_run_variant => "core"}, session_data)
    assert_normal_response('list_by_variant', 4)
    assert_assigned(:host)
    assert_assigned(:variant)
    assert_assigned(:test_runs)
    assert_assigned(:test_run_pages)

    assert_equal(1, assigns(:host).id)
    assert_equal('core', assigns(:variant))
    assert_equal([1], assigns(:test_runs).collect {|r| r.id} )
  end

  def test_show
    id = 1
    test_run = Tdm::TestRun.find(id)
    test_run.variant = 'boo'
    test_run.save!
    get(:show, {:host_name => test_run.host.name, :test_run_variant => test_run.variant, :test_run_id => test_run.id}, session_data)
    assert_normal_response('show', 1)
    assert_assigned(:record)
    assert_equal(id, assigns(:record).id)
  end

  def test_show_summary
    id = 2
    test_run = Tdm::TestRun.find(id)
    get(:show_summary, {:host_name => test_run.host.name, :test_run_variant => test_run.variant, :test_run_id => test_run.id}, session_data)
    assert_normal_response('show_summary', 1)
    assert_assigned(:record)
    assert_equal(id, assigns(:record).id)
  end

  def test_regression_report
    id = 1
    test_run = Tdm::TestRun.find(id)
    get(:regression_report, {:host_name => test_run.host.name, :test_run_variant => test_run.variant, :test_run_id => test_run.id}, session_data)
    assert_normal_response('regression_report', 1)
    assert_assigned(:report)
    assert_equal(id, assigns(:report).test_run.id)
  end

  def test_performance_report
    id = 1
    test_run = Tdm::TestRun.find(id)
    get(:performance_report, {:host_name => test_run.host.name, :test_run_variant => test_run.variant, :test_run_id => test_run.id}, session_data)
    assert_normal_response('performance_report', 1)
    assert_assigned(:report)
    assert_equal(id, assigns(:report).test_run.id)
  end

  def test_destroy
    id = 1
    assert(Tdm::TestRun.exists?(id))
    test_run = Tdm::TestRun.find(id)
    label = test_run.label
    host_name = test_run.host.name
    purge_log

    path = File.expand_path("#{RAILS_ROOT}/public/results/skunk/core/1")
    file = "#{path}.html"
    FileUtils.mkdir_p(path)
    f = File.new(file,  "w+")
    f.write('hi')
    f.close
    assert(File.exists?(path))
    assert(File.exists?(file))

    delete(:destroy, {:host_name => host_name, :test_run_variant => test_run.variant, :test_run_id => test_run.id}, session_data)
    assert_redirected_to(:controller => 'results/host', :action => 'show', :host_name => host_name)
    assert(!Tdm::TestRun.exists?(id))
    assert_assigned(:record)
    assert_equal(id, assigns(:record).id)
    assert_equal(true, assigns(:record).frozen?)
    assert_flash_count(1)
    assert_equal("#{label} was successfully deleted.", flash[:notice])
    assert_logs([["test-run.deleted", 'id=1 (core.1)']], 1)
    assert(!File.exists?(path))
    assert(!File.exists?(file))
  end
end
