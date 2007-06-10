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

class StatisticFactTest < Test::Unit::TestCase
  def test_basic_load
    object = StatisticFact.find(1)
    assert_equal( 1, object.id )
    assert_equal( 1, object.host_id )
    assert_equal( 1, object.host.id )
    assert_equal( 1, object.test_run_id )
    assert_equal( 1, object.test_run.id )
    assert_equal( 1, object.test_configuration_id )
    assert_equal( 1, object.test_configuration.id )
    assert_equal( 1, object.build_configuration_id )
    assert_equal( 1, object.build_configuration.id )
    assert_equal( 1, object.build_target_id )
    assert_equal( 1, object.build_target.id )
    assert_equal( 1, object.test_case_id )
    assert_equal( 1, object.test_case.id )
    assert_equal( 1, object.time_id )
    assert_equal( 1, object.time.id )
    assert_equal( 1, object.revision_id )
    assert_equal( 1, object.revision.id )
    assert_equal( 1, object.statistic_id )
    assert_equal( 1, object.statistic.id )
    assert_equal( 1, object.result_id )
    assert_equal( 1, object.result.id )
    assert_equal( 1, object.source_id )
    assert_equal( 1, object.source.id )
    assert_equal( 10243, object.value )
  end

  def self.attributes_for_new
    {:host_id => 1, :test_run_id => 1, :test_configuration_id => 1, :build_configuration_id => 1, :build_target_id => 1, :test_case_id => 1, :time_id => 1, :revision_id => 1, :statistic_id => 1, :source_id => 1, :value => 23, :result_id => 1}
  end
  def self.non_null_attributes
    [:host_id, :test_run_id, :test_configuration_id, :build_configuration_id, :build_target_id, :test_case_id, :time_id, :revision_id, :statistic_id, :result_id, :value]
  end

  perform_basic_model_tests(:skip => [:destroy])
end
