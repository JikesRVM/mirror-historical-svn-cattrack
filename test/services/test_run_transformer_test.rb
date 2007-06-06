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
    assert_equal( initial_statistic_fact_count + 1 + 13, StatisticFact.count )

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
    assert_equal( 14, results.size )

    timings = results.select{|r| r.statistic.name != 'caffeinemark'}
    assert_equal( 13, timings.size )
    assert_equal( [457, 914, 1371, 1828, 2285, 2742, 3199, 3656, 5941, 6398, 6855, 7312, 7769], timings.collect{|t|t.value}.sort )
    assert_equal( [1, 2, 3, 4, 5, 6, 7, 8, 13, 14, 15, 16, 17], timings.collect{|t|t.source_id}.sort )
    assert_equal( ['basic', 'caffeinemark', 'optests'], timings.collect{|t|t.test_case.group}.uniq.sort )
    assert_equal( ["TestClassLoading", "TestCompares", "TestLotsOfLoops", "TestThrow", "caffeinemark"], timings.collect{|t|t.test_case.name}.uniq.sort )
    assert_equal( ["ia32_linux"], timings.collect{|t|t.build_target.name}.uniq.sort )
    assert_equal( ['prototype', 'prototype-opt', 'prototype_V2'], timings.collect{|t|t.test_configuration.name}.uniq.sort )
    assert_equal( ['rvm.real.time'], timings.collect{|t|t.statistic.name}.uniq.sort )

    caf = results.find{|r| r.statistic.name == 'caffeinemark'}
    assert_not_nil( caf )
    assert_equal( 'caffeinemark', caf.test_case.group )
    assert_equal( 'caffeinemark', caf.test_case.name )
    assert_equal( 'prototype-opt', caf.test_configuration.name )
    assert_equal( 'caffeinemark', caf.statistic.name )
    assert_equal( 54, caf.value )
    assert_equal( 17, caf.source_id )
  end
end
