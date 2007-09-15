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

class Report::RegressionReportTest < Test::Unit::TestCase

  def test_report_with_no_history
    test_run = Tdm::TestRun.find(1)
    report = Report::RegressionReport.new(test_run)
    assert_equal(test_run, report.test_run)
    assert_equal(10, report.window_size)
    assert_equal([], report.missing_tests.collect{|t| t['test_case_id']})
    assert_equal([], report.new_failures.collect{|t| t['test_case_id']})
    assert_equal(report.test_run.test_case_execution_ids.sort, report.new_successes.collect{|t| t['test_case_id'].to_i}.sort)
    assert_equal([], report.intermittent_failures.collect{|t| t['test_case_id']})
    assert_equal([], report.consistent_failures.collect{|t| t['test_case_id']})
    assert_equal([test_run.id], report.test_runs.collect{|tr| tr.id})
    assert_equal([], report.statistics)
    assert_equal([], report.tc_by_tr)
    assert_equal([], report.bc_by_tr)
  end

  def test_report_minimal_history_from_identical_run
    test_run = Tdm::TestRun.find(1)
    test_run_1 = clone_test_run(test_run, 10)

    report = Report::RegressionReport.new(test_run)
    assert_equal(test_run, report.test_run)
    assert_equal([], report.missing_tests.collect{|t| t['test_case_id']})
    assert_equal([], report.new_failures.collect{|t| t['test_case_id']})
    assert_equal([], report.new_successes.collect{|t| t['test_case_id']}.sort)
    assert_equal([], report.consistent_failures.collect{|t| t['test_case_id']})
    assert_equal([], report.intermittent_failures.collect{|t| t['test_case_id']})
    assert_equal([test_run_1.id, test_run.id], report.test_runs.collect{|tr| tr.id})
    assert_equal([], report.statistics)
    assert_equal([], report.tc_by_tr)
    assert_equal([], report.bc_by_tr)
  end

  def test_report_minimal_history_new_successes_and_failures
    test_run = Tdm::TestRun.find(1)
    test_run_1 = clone_test_run(test_run, 10)
    test_case1 = test_run.build_configurations[0].test_configurations[0].groups[0].test_cases[0]
    test_case1.test_case_executions[0].result = 'OVERTIME'
    test_case1.test_case_executions[0].save!

    test_case2 = test_run_1.build_configurations[0].test_configurations[0].groups[0].test_cases[1]
    test_case2.test_case_executions[0].result = 'FAILURE'
    test_case2.test_case_executions[0].save!

    report = Report::RegressionReport.new(Tdm::TestRun.find(1))
    assert_equal(test_run, report.test_run)
    assert_equal([], report.missing_tests.collect{|t| t['test_case_id']})
    assert_equal([test_case2.name], report.new_successes.collect{|t| t['test_case_name']}.sort)
    assert_equal([test_case1.name], report.new_failures.collect{|t| t['test_case_name']})
    assert_equal([], report.intermittent_failures.collect{|t| t['test_case_id']})
    assert_equal([], report.consistent_failures.collect{|t| t['test_case_id']})
    assert_equal([test_run_1.id, test_run.id], report.test_runs.collect{|tr| tr.id})
    assert_equal([], report.statistics)
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

    report = Report::RegressionReport.new(Tdm::TestRun.find(1))
    assert_equal(test_run, report.test_run)
    assert_equal([test_case2.name], report.missing_tests.collect{|t| t['test_case_name']})
    assert_equal([], report.new_successes.collect{|t| t['test_case_name']}.sort)
    assert_equal([], report.new_failures.collect{|t| t['test_case_name']})
    assert_equal([], report.intermittent_failures.collect{|t| t['test_case_id']})
    assert_equal([], report.consistent_failures.collect{|t| t['test_case_id']})
    assert_equal([test_run_1.id, test_run.id], report.test_runs.collect{|tr| tr.id})
    assert_equal([], report.statistics)
    assert_equal([], report.tc_by_tr)
    assert_equal([], report.bc_by_tr)
  end

  def test_report_minimal_history_consistent_and_intermitent_failures
    test_run = Tdm::TestRun.find(1)
    test_run_1 = clone_test_run(test_run, 10)
    test_run_2 = clone_test_run(test_run, 20)

    test_case1 = test_run.build_configurations[0].test_configurations[0].groups[0].test_cases[0]
    test_case1.test_case_executions[0].result = 'OVERTIME'
    test_case1.test_case_executions[0].save!

    test_case2 = test_run_1.build_configurations[0].test_configurations[0].groups[0].test_cases[0]
    test_case2.test_case_executions[0].result = 'OVERTIME'
    test_case2.test_case_executions[0].save!

    test_case3 = test_run_2.build_configurations[0].test_configurations[0].groups[0].test_cases[0]
    test_case3.test_case_executions[0].result = 'OVERTIME'
    test_case3.test_case_executions[0].save!

    test_case2b = test_run_1.build_configurations[0].test_configurations[0].groups[0].test_cases[1]
    test_case2b.test_case_executions[0].result = 'FAILURE'
    test_case2b.test_case_executions[0].save!

    test_case_X = test_run_1.build_configurations[0].test_configurations[0].groups[1].test_cases[0]
    test_case_X.test_case_executions[0].result = 'FAILURE'
    test_case_X.test_case_executions[0].save!

    test_case_Y = test_run.build_configurations[0].test_configurations[0].groups[1].test_cases[0]
    test_case_Y.test_case_executions[0].result = 'FAILURE'
    test_case_Y.test_case_executions[0].save!

    report = nil
    Tdm::TestRun.transaction do
      report = Report::RegressionReport.new(test_run)
    end
    assert_equal(test_run, report.test_run)
    assert_equal([], report.missing_tests.collect{|t| t['test_case_id']})
    assert_equal([], report.new_failures.collect{|t| t['test_case_name']})
    assert_equal([], report.new_successes.collect{|t| t['test_case_name']}.sort)
    assert_equal([test_case1.name], report.consistent_failures.collect{|t| t['test_case_name']})
    assert_equal([test_case2b.name, test_case_Y.name], report.intermittent_failures.collect{|t| t['test_case_name']}.sort)

    assert_equal([test_run_2.id, test_run_1.id, test_run.id], report.test_runs.collect{|tr| tr.id})
    assert_equal([], report.statistics)
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

    report = Report::RegressionReport.new(test_run)
    assert_equal(test_run, report.test_run)
    assert_equal(10, report.window_size)
    assert_equal([], report.missing_tests.collect{|t| t['test_case_id']})
    assert_equal([], report.new_failures.collect{|t| t['test_case_id']})
    assert_equal([], report.new_successes.collect{|t| t['test_case_id']})
    assert_equal([], report.intermittent_failures.collect{|t| t['test_case_id']})
    assert_equal([], report.consistent_failures.collect{|t| t['test_case_id']})
    assert_equal([test_run_1.id, test_run.id], report.test_runs.collect{|tr| tr.id})
    assert_equal([
            {"build_configuration_name"=>"production", "test_configuration_name"=>"Performance", "group_name"=>"SPECjbb2005", "test_case_name"=>"SPECjbb2005", "name"=>"SPECjbb2005", "best_score"=>"22", "std_deviation"=>"0", "test_run_#{test_run_1.id}"=>"22", "test_run_1"=>"22", "less_is_more"=>"0", },
                    {"build_configuration_name"=>"production", "test_configuration_name"=>"Performance", "group_name"=>"SPECjvm98", "test_case_name"=>"SPECjvm98", "name"=>"SPECjvm98", "best_score"=>"412", "std_deviation"=>"0", "test_run_#{test_run_1.id}"=>"412", "test_run_1"=>"412", "less_is_more"=>"0", }
    ], report.statistics)
    assert_equal([], report.tc_by_tr)
    assert_equal([], report.bc_by_tr)
  end
end
