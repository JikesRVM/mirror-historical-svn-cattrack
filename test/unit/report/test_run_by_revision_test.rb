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
  def test_report_with_no_history
    test_run = TestRun.find(1)
    report = Report::TestRunByRevision.new(test_run)
    assert_equal(test_run, report.test_run)
    assert_equal(6, report.window_size)
    assert_equal([], report.new_failures.collect{|t| t.id})
    assert_equal(report.test_run.test_case_ids.sort, report.new_successes.collect{|t| t.id}.sort)
    assert_equal([], report.intermittent_failures.collect{|t| t.id})
    assert_equal([], report.consistent_failures.collect{|t| t.id})
  end

  def test_report_minimal_history_from_identical_run
    test_run = TestRun.find(1)
    test_run_1 = clone_test_run(test_run, 10)

    report = Report::TestRunByRevision.new(test_run)
    assert_equal(test_run, report.test_run)
    assert_equal([], report.new_failures.collect{|t| t.id})
    assert_equal([], report.new_successes.collect{|t| t.id}.sort)
    assert_equal([], report.intermittent_failures.collect{|t| t.id})
    assert_equal([], report.consistent_failures.collect{|t| t.id})
  end

  def test_report_minimal_history_new_successes_and_failures
    test_run = TestRun.find(1)
    test_run_1 = clone_test_run(test_run, 10)
    test_case1 = test_run.build_configurations[0].test_configurations[0].groups[0].test_cases[0]
    test_case1.result = 'OVERTIME'
    test_case1.save!

    test_case2 = test_run_1.build_configurations[0].test_configurations[0].groups[0].test_cases[1]
    test_case2.result = 'FAILURE'
    test_case2.save!

    report = Report::TestRunByRevision.new(test_run)
    assert_equal(test_run, report.test_run)
    assert_equal([test_case1.name], report.new_failures.collect{|t| t.name})
    assert_equal([test_case2.name], report.new_successes.collect{|t| t.name}.sort)
    assert_equal([], report.intermittent_failures.collect{|t| t.id})
    assert_equal([], report.consistent_failures.collect{|t| t.id})
  end

  def test_report_minimal_history_consistent_and_intermitent_failures
    test_run = TestRun.find(1)
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


    report = nil
    TestRun.transaction do
      report = Report::TestRunByRevision.new(test_run)
    end
    assert_equal(test_run, report.test_run)
    assert_equal([], report.new_failures.collect{|t| t.name})
    assert_equal([], report.new_successes.collect{|t| t.name}.sort)
    assert_equal([test_case1.name], report.consistent_failures.collect{|t| t.name})
    assert_equal([test_case2b.name, test_case_Y.name], report.intermittent_failures.collect{|t| t.name}.sort)
  end

  private

  def clone_test_run(_test_run, offset)
    test_run = TestRun.new(_test_run.attributes)
    test_run.revision -= offset
    test_run.occured_at = test_run.occured_at - offset
    test_run.save!

    bt = BuildTarget.new(_test_run.build_target.attributes)
    bt.test_run_id = test_run.id
    bt.save!

    _test_run.build_configurations.each do |_bc|

      bc = BuildConfiguration.new(_bc.attributes)
      bc.test_run_id = test_run.id
      bc.output = 'X'
      bc.save!
      _bc.test_configurations.each do |_tc|
        tc = TestConfiguration.new(_tc.attributes)
        tc.build_configuration_id = bc.id
        tc.save!
        _tc.groups.each do |_g|
          g = Group.new(_g.attributes)
          g.test_configuration_id = tc.id
          g.save!
          _g.test_cases.each do |_t|
            t = TestCase.new(_t.attributes)
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
