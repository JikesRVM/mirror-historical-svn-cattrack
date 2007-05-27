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

class TestRunTransformerTest < Test::Unit::TestCase
  def test_build_olap_model_from
    test_run = TestRun.find(1)
    initial_result_fact_count = ResultFact.count
    initial_statistic_fact_count = StatisticFact.count
    TestRunTransformer.build_olap_model_from(test_run)
    assert_equal( 13, test_run.test_cases.size )
    assert_equal( initial_result_fact_count + 13, ResultFact.count )
    assert_equal( initial_statistic_fact_count + 1, StatisticFact.count )

    # Assume no other statistics created for specific revision
    revision = RevisionDimension.find_by_revision(test_run.revision)
    assert_not_nil(revision)

    results = ResultFact.find_all_by_revision_id(revision.id)
    assert_equal( 13, results.size )
    assert_equal( ['basic', 'caffeinemark', 'optests'], results.collect {|r| r.test_case.group }.uniq.sort )
    assert_equal( ["TestClassLoading", "TestCompares", "TestLotsOfLoops", "TestThrow", "caffeinemark"], results.collect {|r| r.test_case.name }.uniq.sort )
    assert_equal( ["SUCCESS"], results.collect {|r| r.result.name }.uniq.sort )
    results.each {|r| assert_not_nil(r.source_id, "#{r.id} source test") }
    assert_equal( 1, results.collect {|r| r.time_id }.uniq.size )
    assert_equal( 1, results.collect {|r| r.time_id }.uniq.size )
    assert_equal( ['ia32_linux'], results.collect {|r| r.build_target.name }.uniq )
    assert_equal( ['prototype', 'prototype-opt', 'prototype_V2'], results.collect {|r| r.test_configuration.name }.uniq.sort )

    results = StatisticFact.find_all_by_revision_id(revision.id)
    assert_equal( 1, results.size )
    assert_equal( 'caffeinemark', results[0].test_case.group )
    assert_equal( 'caffeinemark', results[0].test_case.name )
    assert_equal( 'prototype-opt', results[0].test_configuration.name )
    assert_equal( 'prototype-opt', results[0].test_configuration.name )
    assert_equal( 54, results[0].value )
    assert_equal( 17, results[0].source_id )
  end
end
