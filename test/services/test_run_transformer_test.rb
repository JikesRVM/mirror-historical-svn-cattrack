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
    test_run = Tdm::TestRun.find(1)
    initial_result_fact_count = Olap::ResultFact.count
    initial_statistic_fact_count = Olap::StatisticFact.count
    TestRunTransformer.build_olap_model_from(test_run)
    assert_equal( 13, test_run.test_cases.size )
    assert_equal( initial_result_fact_count + 13, Olap::ResultFact.count )
    assert_equal( initial_statistic_fact_count + 1 + 13, Olap::StatisticFact.count )

    # Assume no other statistics created for specific revision
    revision = Olap::RevisionDimension.find_by_revision(test_run.revision)
    assert_not_nil(revision)

    results = Olap::ResultFact.find_all_by_revision_id(revision.id)
    assert_equal( 13, results.size )
    assert_equal( ['basic', 'caffeinemark', 'optests'], results.collect {|r| r.test_case.group }.uniq.sort )
    assert_equal( ["TestClassLoading", "TestCompares", "TestLotsOfLoops", "TestThrow", "caffeinemark"], results.collect {|r| r.test_case.name }.uniq.sort )
    assert_equal( ["SUCCESS"], results.collect {|r| r.result.name }.uniq.sort )
    results.each {|r| assert_not_nil(r.source_id, "#{r.id} source test") }
    assert_equal( 1, results.collect {|r| r.time_id }.uniq.size )
    assert_equal( 1, results.collect {|r| r.time_id }.uniq.size )
    assert_equal( ['ia32_linux'], results.collect {|r| r.build_target.name }.uniq )
    assert_equal( ['prototype', 'prototype-opt', 'prototype_V2'], results.collect {|r| r.test_configuration.name }.uniq.sort )

    results = Olap::StatisticFact.find_all_by_revision_id(revision.id)
    assert_equal( 14, results.size )

    timings = results.select{|r| r.statistic.name != 'caffeinemark_numerical'}
    assert_equal( 13, timings.size )
    assert_equal( [457, 914, 1371, 1828, 2285, 2742, 3199, 3656, 5941, 6398, 6855, 7312, 7769], timings.collect{|t|t.value}.sort )
    assert_equal( [1, 2, 3, 4, 5, 6, 7, 8, 13, 14, 15, 16, 17], timings.collect{|t|t.source_id}.sort )
    assert_equal( ['basic', 'caffeinemark', 'optests'], timings.collect{|t|t.test_case.group}.uniq.sort )
    assert_equal( ["TestClassLoading", "TestCompares", "TestLotsOfLoops", "TestThrow", "caffeinemark"], timings.collect{|t|t.test_case.name}.uniq.sort )
    assert_equal( ["ia32_linux"], timings.collect{|t|t.build_target.name}.uniq.sort )
    assert_equal( ['prototype', 'prototype-opt', 'prototype_V2'], timings.collect{|t|t.test_configuration.name}.uniq.sort )
    assert_equal( ['rvm.real.time'], timings.collect{|t|t.statistic.name}.uniq.sort )

    caf = results.find{|r| r.statistic.name == 'caffeinemark_numerical'}
    assert_not_nil( caf )
    assert_equal( 'caffeinemark', caf.test_case.group )
    assert_equal( 'caffeinemark', caf.test_case.name )
    assert_equal( 'prototype-opt', caf.test_configuration.name )
    assert_equal( 'caffeinemark_numerical', caf.statistic.name )
    assert_equal( 54, caf.value )
    assert_equal( 17, caf.source_id )
  end

  def test_build_olap_model_from_test_run_with_failed_build
    test_run = Tdm::TestRun.find(1)

    # Set up test run like it would appear if failed to build
    failed_bc = test_run.build_configurations[1]
    failed_bc.test_configurations.destroy_all
    failed_bc.result = 'FAILURE'
    failed_bc.params.clear
    failed_bc.save!

    Olap::ResultFact.destroy_all
    Olap::StatisticFact.destroy_all

    test_run = Tdm::TestRun.find(1)
    initial_result_fact_count = Olap::ResultFact.count
    initial_statistic_fact_count = Olap::StatisticFact.count
    TestRunTransformer.build_olap_model_from(test_run)
    test_run = Tdm::TestRun.find(1)

    assert_equal( 8, test_run.test_cases.size )
    assert_equal( initial_result_fact_count + 8, Olap::ResultFact.count )
    assert_equal( initial_statistic_fact_count + 8, Olap::StatisticFact.count )

    # Assume no other statistics created for specific revision
    revision = Olap::RevisionDimension.find_by_revision(test_run.revision)
    assert_not_nil(revision)

    results = Olap::ResultFact.find_all_by_revision_id(revision.id)
    assert_equal( 8, results.size )
    assert_equal( ['basic', 'optests'], results.collect {|r| r.test_case.group }.uniq.sort )
    assert_equal( ["TestClassLoading", "TestCompares", "TestLotsOfLoops", "TestThrow"], results.collect {|r| r.test_case.name }.uniq.sort )
    assert_equal( ["SUCCESS"], results.collect {|r| r.result.name }.uniq.sort )
    results.each {|r| assert_not_nil(r.source_id, "#{r.id} source test") }
    assert_equal( 1, results.collect {|r| r.time_id }.uniq.size )
    assert_equal( 1, results.collect {|r| r.time_id }.uniq.size )
    assert_equal( ['ia32_linux'], results.collect {|r| r.build_target.name }.uniq )
    assert_equal( ['prototype', 'prototype_V2'], results.collect {|r| r.test_configuration.name }.uniq.sort )

    results = Olap::StatisticFact.find_all_by_revision_id(revision.id)
    assert_equal( 8, results.size )

    assert_equal( 8, results.size )
    assert_equal( [457.0, 914.0, 1371.0, 1828.0, 2285.0, 2742.0, 3199.0, 3656.0], results.collect{|t|t.value}.sort )
    assert_equal( [1, 2, 3, 4, 5, 6, 7, 8], results.collect{|t|t.source_id}.sort )
    assert_equal( ['basic', 'optests'], results.collect{|t|t.test_case.group}.uniq.sort )
    assert_equal( ["TestClassLoading", "TestCompares", "TestLotsOfLoops", "TestThrow"], results.collect{|t|t.test_case.name}.uniq.sort )
    assert_equal( ["ia32_linux"], results.collect{|t|t.build_target.name}.uniq.sort )
    assert_equal( ['prototype', 'prototype_V2'], results.collect{|t|t.test_configuration.name}.uniq.sort )
    assert_equal( ['rvm.real.time'], results.collect{|t|t.statistic.name}.uniq.sort )
  end
end
