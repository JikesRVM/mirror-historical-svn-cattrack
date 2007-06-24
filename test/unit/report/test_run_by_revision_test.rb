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

  def olappy(id)
    TestRunTransformer.build_olap_model_from(Tdm::TestRun.find(id))
  end

  def test_report_with_no_history
    test_run = Tdm::TestRun.find(1)
    olappy(test_run.id)
    report = Report::TestRunByRevision.new(test_run)
    assert_equal(test_run, report.test_run)
    assert_equal(6, report.window_size)
    assert_equal([], report.perf_stats)
    assert_equal([], report.missing_tests.collect{|t| t['test_case_id']})
    assert_equal([], report.new_failures.collect{|t| t['test_case_id']})
    assert_equal(report.test_run.test_case_ids.sort, report.new_successes.collect{|t| t['test_case_id'].to_i}.sort)
    assert_equal([], report.intermittent_failures.collect{|t| t['test_case_id']})
    assert_equal([], report.consistent_failures.collect{|t| t['test_case_id']})
    assert_equal([nil, "core-1"], report.tcn_by_tr_headers)
    assert_equal([], report.tcn_by_tr)
  end

  def test_report_minimal_history_from_identical_run
    test_run = Tdm::TestRun.find(1)
    test_run_1 = clone_test_run(test_run, 10)

    olappy(test_run.id)
    olappy(test_run_1.id)
    report = Report::TestRunByRevision.new(test_run)
    assert_equal(test_run, report.test_run)
    assert_equal([], report.perf_stats)
    assert_equal([], report.missing_tests.collect{|t| t['test_case_id']})
    assert_equal([], report.new_failures.collect{|t| t['test_case_id']})
    assert_equal([], report.new_successes.collect{|t| t['test_case_id']}.sort)
    assert_equal([], report.consistent_failures.collect{|t| t['test_case_id']})
    assert_equal([], report.intermittent_failures.collect{|t| t['test_case_id']})
    assert_equal([nil, "core-1", "core-#{test_run_1.id}"], report.tcn_by_tr_headers)
    assert_equal([], report.tcn_by_tr)
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
    assert_equal([], report.perf_stats)
    assert_equal([], report.missing_tests.collect{|t| t['test_case_id']})
    assert_equal([test_case2.name], report.new_successes.collect{|t| t['test_case_name']}.sort)
    assert_equal([test_case1.name], report.new_failures.collect{|t| t['test_case_name']})
    assert_equal([], report.intermittent_failures.collect{|t| t['test_case_id']})
    assert_equal([], report.consistent_failures.collect{|t| t['test_case_id']})
    assert_equal([nil, "core-1", "core-#{test_run_1.id}"], report.tcn_by_tr_headers)
    assert_equal([
    ["TestClassLoading", "66.6666666666667", "100", 166],
    ["TestCompares", "100", "66.6666666666667", 166]
    ], report.tcn_by_tr)
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
    assert_equal([], report.perf_stats)
    assert_equal([test_case2.name], report.missing_tests.collect{|t| t['test_case_name']})
    assert_equal([], report.new_successes.collect{|t| t['test_case_name']}.sort)
    assert_equal([], report.new_failures.collect{|t| t['test_case_name']})
    assert_equal([], report.intermittent_failures.collect{|t| t['test_case_id']})
    assert_equal([], report.consistent_failures.collect{|t| t['test_case_id']})
    assert_equal([nil, "core-1", "core-#{test_run_1.id}"], report.tcn_by_tr_headers)
    assert_equal([], report.tcn_by_tr)
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
    assert_equal([], report.perf_stats)
    assert_equal([], report.missing_tests.collect{|t| t['test_case_id']})
    assert_equal([], report.new_failures.collect{|t| t['test_case_name']})
    assert_equal([], report.new_successes.collect{|t| t['test_case_name']}.sort)
    assert_equal([test_case1.name], report.consistent_failures.collect{|t| t['test_case_name']})
    assert_equal([test_case2b.name, test_case_Y.name], report.intermittent_failures.collect{|t| t['test_case_name']}.sort)
    assert_equal([nil, "core-1", "core-#{test_run_1.id}", "core-#{test_run_2.id}"], report.tcn_by_tr_headers)
    assert_equal([
    ["TestClassLoading", "66.6666666666667", "66.6666666666667", "66.6666666666667", 200],
    ["TestLotsOfLoops", "66.6666666666667", "66.6666666666667", "100", 233],
    ["TestCompares", "100", "66.6666666666667", "100", 266]
    ], report.tcn_by_tr)
  end

  def test_report_with_perf_stats
    test_run = create_test_run_for_perf_tests
    test_run_1 = clone_test_run(test_run, 10)

    olappy(test_run.id)
    olappy(test_run_1.id)
    report = Report::TestRunByRevision.new(test_run)
    assert_equal(test_run, report.test_run)
    assert_equal(6, report.window_size)
    assert_equal([['SPECjvm98','412','412'],['SPECjbb2005','22','22']], report.perf_stats)
    assert_equal([], report.missing_tests.collect{|t| t['test_case_id']})
    assert_equal([], report.new_failures.collect{|t| t['test_case_id']})
    assert_equal([], report.new_successes.collect{|t| t['test_case_id']})
    assert_equal([], report.intermittent_failures.collect{|t| t['test_case_id']})
    assert_equal([], report.consistent_failures.collect{|t| t['test_case_id']})
    assert_equal([nil, "core-1", "core-#{test_run_1.id}"], report.tcn_by_tr_headers)
    assert_equal([], report.tcn_by_tr)
  end

  private

  def create_test_run_for_perf_tests
    test_run = Tdm::TestRun.find(1)
    test_run.build_configurations[1].destroy
    build_configuration = test_run.build_configurations[0]
    build_configuration.name = 'production'
    build_configuration.save!
    assert_equal(2, build_configuration.test_configurations.size)
    build_configuration.test_configurations[1].destroy

    test_configuration = build_configuration.test_configurations[0]
    test_configuration.name = 'Performance'
    test_configuration.save!
    assert_equal(2, test_configuration.groups.size)
    group = test_configuration.groups[1]
    group.name = 'SPECjvm98'
    group.save!
    assert_equal(2, group.test_cases.size)
    group.test_cases[1].destroy
    group.test_cases[0].name = 'SPECjvm98'
    group.test_cases[0].statistics.clear
    group.test_cases[0].statistics['aggregate.best.score'] = '412'
    group.test_cases[0].save!

    group = test_configuration.groups[0]
    group.name = 'SPECjbb2005'
    group.save!
    assert_equal(2, group.test_cases.size)
    group.test_cases[1].destroy
    group.test_cases[0].name = 'SPECjbb2005'
    group.test_cases[0].statistics.clear
    group.test_cases[0].statistics['score'] = '22'
    group.test_cases[0].save!

    test_run = Tdm::TestRun.find(1)
    assert_equal(1, test_run.build_configurations.size)
    assert_equal('production', test_run.build_configurations[0].name)
    assert_equal(1, test_run.build_configurations[0].test_configurations.size)
    assert_equal('Performance', test_run.build_configurations[0].test_configurations[0].name)
    assert_equal(2, test_run.build_configurations[0].test_configurations[0].groups.size)

    assert_equal('SPECjbb2005', test_run.build_configurations[0].test_configurations[0].groups[0].name)
    assert_equal(1, test_run.build_configurations[0].test_configurations[0].groups[0].test_cases.size)
    assert_equal('SPECjbb2005', test_run.build_configurations[0].test_configurations[0].groups[0].test_cases[0].name)

    assert_equal('SPECjvm98', test_run.build_configurations[0].test_configurations[0].groups[1].name)
    assert_equal(1, test_run.build_configurations[0].test_configurations[0].groups[1].test_cases.size)
    assert_equal('SPECjvm98', test_run.build_configurations[0].test_configurations[0].groups[1].test_cases[0].name)

    Tdm::TestRun.find(1)
  end

  def clone_test_run(_test_run, offset)
    test_run = Tdm::TestRun.new(_test_run.attributes)
    test_run.revision -= offset
    test_run.occurred_at = test_run.occurred_at - offset
    test_run.save!

    bt = Tdm::BuildTarget.new(_test_run.build_target.attributes)
    bt.test_run_id = test_run.id
    _test_run.build_target.params.each_pair do |k, v|
      bt.params[k] = v
    end
    bt.save!

    _test_run.build_configurations.each do |_bc|

      bc = Tdm::BuildConfiguration.new(_bc.attributes)
      _bc.params.each_pair do |k, v|
        bc.params[k] = v
      end
      bc.test_run_id = test_run.id
      bc.output = 'X'
      bc.save!
      _bc.test_configurations.each do |_tc|
        tc = Tdm::TestConfiguration.new(_tc.attributes)
        _tc.params.each_pair do |k, v|
          tc.params[k] = v
        end
        tc.build_configuration_id = bc.id
        tc.save!
        _tc.groups.each do |_g|
          g = Tdm::Group.new(_g.attributes)
          g.test_configuration_id = tc.id
          g.save!
          _g.test_cases.each do |_t|
            t = Tdm::TestCase.new(_t.attributes)
            _t.params.each_pair do |k, v|
              t.params[k] = v
            end
            _t.statistics.each_pair do |k, v|
              t.statistics[k] = v
            end
            t.group_id = g.id
            t.output = 'X'
            _t.statistics.each_pair do |k, v|
              t.statistics[k] = v
            end
            t.save!
          end
        end
      end
    end
    test_run
  end
end
