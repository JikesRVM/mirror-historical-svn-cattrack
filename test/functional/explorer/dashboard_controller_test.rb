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
require 'explorer/dashboard_controller'

class Explorer::DashboardController
  # Re-raise errors caught by the controller.
  def rescue_action(e)
    raise e
  end
end

class Explorer::DashboardControllerTest < Test::Unit::TestCase
  def setup
    @controller = Explorer::DashboardController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get(:index, {}, {:user_id => 1})
    assert_normal_response('index', 6 + 15)
    assert_dimension_assigns
    assert_assigned(:presentations)
    assert_assigned(:measures)
    assert_assigned(:filters)
    # measure assigned but null
    #assert_assigned(:measure)
    assert_assigned(:filter)
    assert_assigned(:query)

    assert_equal('Success Rate', assigns(:query).measure.name )
    assert_equal('test_configuration_name', assigns(:query).primary_dimension )
    assert_equal('revision_revision', assigns(:query).secondary_dimension )

    assert_equal([1, 3, 2], assigns(:presentations).collect {|r| r.id} )
    assert_equal([5, 3, 2, 4, 1], assigns(:measures).collect {|r| r.id} )
    assert_equal([2, 1], assigns(:filters).collect {|r| r.id} )
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
    [:build_configuration_mmtk_plans, ["org.mmtk.plan.generational.marksweep.GenMS"]]
    ].each do |v|
      assert_assigned(v[0])
      assert_equal(v[1], assigns(v[0]), "Values for assign #{v[0]}")
    end
  end
end
