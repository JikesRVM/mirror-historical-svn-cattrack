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
require 'explorer/filter_controller'

class Explorer::FilterController
  # Re-raise errors caught by the controller.
  def rescue_action(e)
    raise e
  end
end

class Explorer::FilterControllerTest < Test::Unit::TestCase

  def setup
    @controller = Explorer::FilterController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def session_data
    {:user_id => 1}
  end

  def test_list
    get(:list, {}, session_data)
    assert_response(:success)
    assert_normal_response('list', 2)
    assert_assigned(:filter_pages)
    assert_assigned(:filters)

    assert_equal([2, 1], assigns(:filters).collect {|r| r.id} )
    assert_equal(0, assigns(:filter_pages).current.offset)
    assert_equal(1, assigns(:filter_pages).page_count)
  end

  def assert_standard_edit_assigns
    [
    [:test_run_names, ["core"]],
    [:test_run_variants, ["core"]],
    [:build_target_names, ["ia32_linux"]],
    [:build_configuration_bootimage_class_inclusion_policies, ["complete", "minimal"]],
    [:build_target_address_sizes, ["32"]],
    [:test_configuration_modes, ["", "gcstress", "performance"]],
    [:build_target_arches, ["ia32"]],
    [:host_names, ["helm", "skunk"]],
    [:test_configuration_names, ["development", "performance_production", "prototype", "prototype-opt"]],
    [:build_configuration_names, ["development", "prototype", "prototype-opt"]],
    [:build_configuration_bootimage_compilers, ["base", "opt"]],
    [:build_configuration_runtime_compilers, ["base", "opt"]],
    [:build_target_operating_systems, ["Linux"]],
    [:build_configuration_assertion_levels, ["normal"]],
    [:result_names, ["FAILURE", "OVERTIME", "SUCCESS"]],
    [:build_configuration_mmtk_plans, ["org.mmtk.plan.generational.marksweep.GenMS"]],
    [:test_case_groups, ["basic"]],
    [:test_case_names, ["ImageSizes", "TestSuspend"]],
    [:statistic_names, ["score", "time"]]
    ].each do |v|
      assert_assigned(v[0])
      assert_equal(v[1], assigns(v[0]), "Values for assign #{v[0]}")
    end
  end

  def test_new_get
    get(:new, {}, session_data)
    assert_normal_response('new', 1 + 19)
    assert_standard_edit_assigns
    assert_new_record(:filter)
  end

  def test_new_post_with_error
    post(:new, {:filter => {:name => '', :description => '', :revision_after => '123'}}, session_data)
    assert_normal_response('new', 1 + 19)
    assert_standard_edit_assigns
    assert_new_record(:filter)
    assert_error_on(:filter, :name)
  end

  def test_new_post
    purge_log
    post(:new, {:filter => {:name => 'X', :description => '', :revision_after => '123'}}, session_data)
    assert_redirected_to(:action => 'list')
    assert_assigns_count(1)
    assert_flash_count(1)
    assert_assigned(:filter)
    assert_equal(false, assigns(:filter).new_record?)
    assert_equal('123', assigns(:filter).revision_after)
    assert_flash(:notice, "Filter named 'X' was successfully created.")
    assert_logs([["filter.created", "id=#{assigns(:filter).id} (X)"]], 1)
  end

  def test_edit_get
    get(:edit, {:id => 1}, session_data)
    assert_response(:success)
    assert_normal_response('edit', 1 + 19)
    assert_standard_edit_assigns
    assert_equal(1, assigns(:filter).id)
  end

  def test_edit_post_with_error
    post(:edit, {:id => 1, :filter => {:name => '', :description => '', :revision_after => '123'}}, session_data)
    assert_normal_response('edit', 1 + 19)
    assert_standard_edit_assigns
    assert_equal(1, assigns(:filter).id)
    assert_error_on(:filter, :name)
  end

  def test_edit_post
    purge_log
    post(:edit, {:id => 1, :filter => {:name => 'X', :description => '', :revision_after => '123'}}, session_data)
    assert_redirected_to(:action => 'list')
    assert_assigns_count(1)
    assert_flash_count(1)
    assert_assigned(:filter)
    assert_equal(1, assigns(:filter).id)
    assert_equal('123', assigns(:filter).revision_after)
    assert_flash(:notice, "Filter named 'X' was successfully saved.")
    assert_logs([["filter.updated", "id=#{assigns(:filter).id} (X)"]], 1)
  end

  def test_destroy
    id = 1
    assert(Olap::Query::Filter.exists?(id))
    purge_log
    post(:destroy, {:id => id}, session_data)
    assert_redirected_to(:action => 'list')
    assert_assigns_count(0)
    assert_flash_count(1)
    assert_flash(:notice, "Filter named 'Last Week' was successfully deleted.")
    assert(!Olap::Query::Filter.exists?(id))
    assert_logs([["filter.deleted", "id=1 (Last Week)"]], 1)
  end
end
