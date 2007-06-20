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

  def test_adhoc
    get(:adhoc, {}, {:user_id => 1})
    assert_normal_response('adhoc', 6 + 17)
    assert_adhoc_params

    #defaults
    assert_equal('Success Rate', assigns(:query).measure.name )
    assert_equal('test_configuration_name', assigns(:query).primary_dimension )
    assert_equal('revision_revision', assigns(:query).secondary_dimension )
  end

  def assert_adhoc_params
    assert_dimension_assigns
    assert_assigned(:presentations)
    assert_assigned(:measures)
    assert_assigned(:filters)
    # measure assigned but null
    #assert_assigned(:measure)
    assert_assigned(:filter)
    assert_assigned(:query)

    assert_equal([1, 3, 2], assigns(:presentations).collect {|r| r.id} )
    assert_equal([5, 3, 2, 4, 1], assigns(:measures).collect {|r| r.id} )
    assert_equal([2, 1], assigns(:filters).collect {|r| r.id} )
  end

  def test_adhoc_post
    purge_log
    post(:adhoc, {'presentation' => 1, :query => {:measure_id => 1, :primary_dimension => 'test_configuration_name', :secondary_dimension => 'test_case_name'} }, {:user_id => 1})
    assert_normal_response('adhoc', 2 + 6 + 17)
    assert_adhoc_params

    assert_equal(1, assigns(:query).measure.id )
    assert_equal('test_configuration_name', assigns(:query).primary_dimension )
    assert_equal('test_case_name', assigns(:query).secondary_dimension )

    assert_assigned(:results)
    assert_assigned(:presentation)
    assert_equal(1, assigns(:presentation).id )

    assert_logs([["report.query", "measure_name = Success Rate, primary_dimension = test_configuration_name, secondary_dimension = test_case_name, presentation_key = pivot, measure_id = 1, presentation_id = 1"]], 1)
  end

  def assert_dimension_assigns
    [
    [:test_run_names, ["core"]],
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
    [:result_names, ["EXCLUDED", "FAILURE", "OVERTIME", "SUCCESS"]],
    [:build_configuration_mmtk_plans, ["org.mmtk.plan.generational.marksweep.GenMS"]],
    [:test_case_groups, ["basic"]],
    [:test_case_names, ["ImageSizes", "TestSuspend"]]
    ].each do |v|
      assert_assigned(v[0])
      assert_equal(v[1], assigns(v[0]), "Values for assign #{v[0]}")
    end
  end

  def test_public_list
    get(:public_list, {}, session_data)
    assert_response(:success)
    assert_normal_response('public_list', 2)
    assert_assigned(:report_pages)
    assert_assigned(:reports)

    assert_equal([1], assigns(:reports).collect {|r| r.id} )
    assert_equal(0, assigns(:report_pages).current.offset)
    assert_equal(1, assigns(:report_pages).page_count)
  end

  def test_show_missing_key
    assert_raises(CatTrack::SecurityError) {get(:show, {:key => 'X'}, session_data)}
  end

  def test_show
    get(:show, {:key => 'SRxBNxW'}, session_data)
    assert_response(:success)
    assert_normal_response('show', 2)
    assert_assigned(:report)
    assert_assigned(:results)
    assert_equal(1, assigns(:report).id)
  end

  def test_list
    get(:list, {}, session_data)
    assert_response(:success)
    assert_normal_response('list', 2)
    assert_assigned(:report_pages)
    assert_assigned(:reports)

    assert_equal([1], assigns(:reports).collect {|r| r.id} )
    assert_equal(0, assigns(:report_pages).current.offset)
    assert_equal(1, assigns(:report_pages).page_count)
  end

  def assert_standard_edit_assigns
    assert_assigned(:presentations)
    assert_assigned(:queries)
    assert_assigned(:report)
    assert_equal([1, 3, 2], assigns(:presentations).collect {|r| r.id} )
    assert_equal([1], assigns(:queries).collect {|r| r.id} )
  end

  def test_new_get
    get(:new, {}, session_data)
    assert_normal_response('new', 1 + 2)
    assert_standard_edit_assigns
    assert_new_record(:report)
  end

  def test_new_post_with_error
    post(:new, {:report => {:name => '', :description => '', :query_id => 1, :presentation_id => 1}}, session_data)
    assert_normal_response('new', 1 + 2)
    assert_standard_edit_assigns
    assert_new_record(:report)
    assert_error_on(:report, :name)
  end

  def test_new_post
    purge_log
    post(:new, {:report => {:name => 'X', :description => '', :query_id => 1, :presentation_id => 1, :key => 'x'}}, session_data)
    assert_redirected_to(:action => 'list')
    assert_assigns_count(1)
    assert_flash_count(1)
    assert_assigned(:report)
    assert_equal(false, assigns(:report).new_record?)
    assert_equal(1, assigns(:report).query_id)
    assert_equal(1, assigns(:report).presentation_id)
    assert_equal('x', assigns(:report).key)
    assert_flash(:notice, "Report named 'X' was successfully created.")
    assert_logs([["report.created", "id=#{assigns(:report).id} (X)"]], 1)
  end

  def test_edit_get
    get(:edit, {:id => 1}, session_data)
    assert_normal_response('edit', 1 + 2)
    assert_standard_edit_assigns
    assert_equal(1, assigns(:report).id)
  end

  def test_edit_post_with_error
    post(:edit, {:id => 1, :report => {:name => '', :description => '', :query_id => 1, :presentation_id => 1}}, session_data)
    assert_normal_response('edit', 1 + 2)
    assert_standard_edit_assigns
    assert_equal(1, assigns(:report).id)
    assert_error_on(:report, :name)
  end

  def test_edit_post
    purge_log
    post(:edit, {:id => 1, :report => {:name => 'X', :description => '', :query_id => 1, :presentation_id => 1}}, session_data)
    assert_redirected_to(:action => 'list')
    assert_assigns_count(1)
    assert_flash_count(1)
    assert_assigned(:report)
    assert_equal(1, assigns(:report).id)
    assert_equal(1, assigns(:report).query_id)
    assert_equal(1, assigns(:report).presentation_id)
    assert_flash(:notice, "Report named 'X' was successfully saved.")
    assert_logs([["report.updated", "id=#{assigns(:report).id} (X)"]], 1)
  end

  def test_destroy
    purge_log
    id = 1
    assert(Olap::Query::Report.exists?(id))
    post(:destroy, {:id => id}, session_data)
    assert_redirected_to(:action => 'list')
    assert_assigns_count(0)
    assert_flash_count(1)
    assert_flash(:notice, "Report named 'Success Rate by Build Configuration by Day of Week Report' was successfully deleted.")
    assert(!Olap::Query::Report.exists?(id))
    assert_logs([["report.deleted", "id=1 (Success Rate by Build Configuration by Day of Week Report)"]], 1)
  end
end
