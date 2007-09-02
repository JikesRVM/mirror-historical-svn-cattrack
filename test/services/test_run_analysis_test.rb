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

class TestRunAnalysisTest < Test::Unit::TestCase
  def test_analysis
    test_run = create_test_run_for_perf_tests
    test_case = test_run.build_configurations[0].test_configurations[0].groups[0].test_cases[0]
    execution = Tdm::TestCaseExecution.new
    execution.test_case_id = test_case.id
    execution.name = 'a'
    execution.time = 10
    execution.exit_code = 0
    execution.result = 'SUCCESS'
    execution.result_explanation = ''
    execution.output = '...'
    execution.numerical_statistics['score'] = '24'
    execution.save!

    execution = Tdm::TestCaseExecution.new
    execution.test_case_id = test_case.id
    execution.name = 'b'
    execution.time = 10
    execution.exit_code = 0
    execution.result = 'FAILURE'
    execution.result_explanation = 'Broken!'
    execution.output = '...'
    execution.save!

    TestRunAnalysis.perform_analysis(Tdm::TestRun.find(test_run.id))
    test_case.reload
    assert_equal(1, test_case.statistics.size)
    assert_equal('23', test_case.statistics['score'])
  end
end
