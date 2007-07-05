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

class Report::TestRunByRevisionTest < Test::Unit::TestCase

  def setup
    Olap::ResultFact.destroy_all
    Olap::StatisticFact.destroy_all
  end

  def test_report_with_no_history
    test_run = Tdm::TestRun.find(1)
    olappy(test_run.id)
    report = Report::TestRunByRevision.new(test_run)
    assert_equal(test_run, report.test_run)
    assert_equal(6, report.window_size)
    assert_equal([], report.missing_tests.collect{|t| t['test_case_id']})
    assert_equal([], report.new_failures.collect{|t| t['test_case_id']})
    assert_equal(report.test_run.test_case_ids.sort, report.new_successes.collect{|t| t['test_case_id'].to_i}.sort)
    assert_equal([], report.intermittent_failures.collect{|t| t['test_case_id']})
    assert_equal([], report.consistent_failures.collect{|t| t['test_case_id']})
    assert_equal(["13/13"], report.success_rates)
    assert_equal([], report.perf_stats)
    assert_equal([], report.tc_by_tr)
    assert_equal([], report.bc_by_tr)
  end

  def test_report_minimal_history_from_identical_run
    test_run = Tdm::TestRun.find(1)
    test_run_1 = clone_test_run(test_run, 10)

    olappy(test_run.id)
    olappy(test_run_1.id)
    report = Report::TestRunByRevision.new(test_run)
    assert_equal(test_run, report.test_run)
    assert_equal([], report.missing_tests.collect{|t| t['test_case_id']})
    assert_equal([], report.new_failures.collect{|t| t['test_case_id']})
    assert_equal([], report.new_successes.collect{|t| t['test_case_id']}.sort)
    assert_equal([], report.consistent_failures.collect{|t| t['test_case_id']})
    assert_equal([], report.intermittent_failures.collect{|t| t['test_case_id']})
    assert_equal(["13/13", "13/13"], report.success_rates)
    assert_equal([], report.perf_stats)
    assert_equal([], report.tc_by_tr)
    assert_equal([], report.bc_by_tr)
  end

  def test_report_minimal_history_new_successes_and_failures
    test_run = Tdm::TestRun.find(1)
    test_run_1 = clone_test_run(test_run, 10)
    test_case1 = test_run.build_configurations[0].test_configurations[0].groups[0].test_cases[0]
    test_case1.result = 'OVERTIME'
    test_case1.save!

    test_case2 = test_run_1.build_configurations[0].test_configurations[0].groups[0].test_cases[1]
    test_case2.result = 'FAILURE'
    test_case2.save!

    olappy(test_run.id)
    olappy(test_run_1.id)
    report = Report::TestRunByRevision.new(Tdm::TestRun.find(1))
    assert_equal(test_run, report.test_run)
    assert_equal([], report.missing_tests.collect{|t| t['test_case_id']})
    assert_equal([test_case2.name], report.new_successes.collect{|t| t['test_case_name']}.sort)
    assert_equal([test_case1.name], report.new_failures.collect{|t| t['test_case_name']})
    assert_equal([], report.intermittent_failures.collect{|t| t['test_case_id']})
    assert_equal([], report.consistent_failures.collect{|t| t['test_case_id']})
    assert_equal(["12/13", "12/13"], report.success_rates)
    assert_equal([], report.perf_stats)
    assert_equal([
    {"test_run_#{test_run_1.id}"=>"100", "test_case_name"=>"TestClassLoading", "test_run_1"=>"67"},
    {"test_run_#{test_run_1.id}"=>"67", "test_case_name"=>"TestCompares", "test_run_1"=>"100"}
    ], report.tc_by_tr)
    assert_equal([
    {"test_run_#{test_run_1.id}"=>"88", "test_run_1"=>"88", "build_configuration_name"=>"prototype"}
    ], report.bc_by_tr)
  end

  def test_report_minimal_history_missing_tests
    test_run = Tdm::TestRun.find(1)
    test_run_1 = clone_test_run(test_run, 10)
    test_case2 = test_run.build_configurations[0].test_configurations[0].groups[0].test_cases[1]
    assert(test_case2.destroy)

    olappy(Tdm::TestRun.find(1))
    olappy(Tdm::TestRun.find(test_run_1.id))
    report = Report::TestRunByRevision.new(Tdm::TestRun.find(1))
    assert_equal(test_run, report.test_run)
    assert_equal([test_case2.name], report.missing_tests.collect{|t| t['test_case_name']})
    assert_equal([], report.new_successes.collect{|t| t['test_case_name']}.sort)
    assert_equal([], report.new_failures.collect{|t| t['test_case_name']})
    assert_equal([], report.intermittent_failures.collect{|t| t['test_case_id']})
    assert_equal([], report.consistent_failures.collect{|t| t['test_case_id']})
    assert_equal(["12/12", "13/13"], report.success_rates)
    assert_equal([], report.perf_stats)
    assert_equal([], report.tc_by_tr)
    assert_equal([], report.bc_by_tr)
  end

  def test_report_minimal_history_consistent_and_intermitent_failures
    test_run = Tdm::TestRun.find(1)
    test_run_1 = clone_test_run(test_run, 10)
    test_run_2 = clone_test_run(test_run, 20)

    test_case1 = test_run.build_configurations[0].test_configurations[0].groups[0].test_cases[0]
    test_case1.result = 'OVERTIME'
    test_case1.save!

    test_case2 = test_run_1.build_configurations[0].test_configurations[0].groups[0].test_cases[0]
    test_case2.result = 'OVERTIME'
    test_case2.save!

    test_case3 = test_run_2.build_configurations[0].test_configurations[0].groups[0].test_cases[0]
    test_case3.result = 'OVERTIME'
    test_case3.save!

    test_case2b = test_run_1.build_configurations[0].test_configurations[0].groups[0].test_cases[1]
    test_case2b.result = 'FAILURE'
    test_case2b.save!

    test_case_X = test_run_1.build_configurations[0].test_configurations[0].groups[1].test_cases[0]
    test_case_X.result = 'FAILURE'
    test_case_X.save!

    test_case_Y = test_run.build_configurations[0].test_configurations[0].groups[1].test_cases[0]
    test_case_Y.result = 'FAILURE'
    test_case_Y.save!

    olappy(test_run.id)
    olappy(test_run_1.id)
    olappy(test_run_2.id)
    report = nil
    Tdm::TestRun.transaction do
      report = Report::TestRunByRevision.new(test_run)
    end
    assert_equal(test_run, report.test_run)
    assert_equal([], report.missing_tests.collect{|t| t['test_case_id']})
    assert_equal([], report.new_failures.collect{|t| t['test_case_name']})
    assert_equal([], report.new_successes.collect{|t| t['test_case_name']}.sort)
    assert_equal([test_case1.name], report.consistent_failures.collect{|t| t['test_case_name']})
    assert_equal([test_case2b.name, test_case_Y.name], report.intermittent_failures.collect{|t| t['test_case_name']}.sort)

    assert_equal(["11/13", "10/13", "12/13"], report.success_rates)
    assert_equal([], report.perf_stats)
    assert_equal([
    {"test_run_#{test_run_1.id}"=>"67", "test_run_#{test_run_2.id}"=>"67", "test_case_name"=>"TestClassLoading", "test_run_1"=>"67"},
    {"test_run_#{test_run_1.id}"=>"67", "test_run_#{test_run_2.id}"=>"100", "test_case_name"=>"TestLotsOfLoops", "test_run_1"=>"67"},
    {"test_run_#{test_run_1.id}"=>"67","test_run_#{test_run_2.id}"=>"100","test_case_name"=>"TestCompares","test_run_1"=>"100"}
    ], report.tc_by_tr)
    assert_equal([
    {"test_run_#{test_run_1.id}"=>"62","test_run_#{test_run_2.id}"=>"88","test_run_1"=>"75","build_configuration_name"=>"prototype"}
    ], report.bc_by_tr)
  end

  def test_report_with_perf_stats
    test_run = create_test_run_for_perf_tests
    test_run_1 = clone_test_run(test_run, 10)

    olappy(test_run.id)
    olappy(test_run_1.id)
    report = Report::TestRunByRevision.new(test_run)
    assert_equal(test_run, report.test_run)
    assert_equal(6, report.window_size)
    assert_equal(["2/2", "2/2"], report.success_rates)
    assert_equal([
    {"name"=>"SPECjbb2005","best_score"=>"22","std_deviation"=>"0","test_run_#{test_run_1.id}"=>"22","test_run_1"=>"22"},
    {"name"=>"SPECjvm98","best_score"=>"412","std_deviation"=>"0","test_run_#{test_run_1.id}"=>"412","test_run_1"=>"412"}
    ],report.perf_stats)
    assert_equal([], report.missing_tests.collect{|t| t['test_case_id']})
    assert_equal([], report.new_failures.collect{|t| t['test_case_id']})
    assert_equal([], report.new_successes.collect{|t| t['test_case_id']})
    assert_equal([], report.intermittent_failures.collect{|t| t['test_case_id']})
    assert_equal([], report.consistent_failures.collect{|t| t['test_case_id']})
    assert_equal([], report.tc_by_tr)
    assert_equal([], report.bc_by_tr)
  end
end
