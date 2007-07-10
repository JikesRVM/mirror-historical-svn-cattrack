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
class Report::TestRunByRevision < Report::BaseTestRunByRevision
  # Input parameters
  attr_reader :test_run, :window_size

  # Output parameters
  attr_reader :test_runs, :new_failures, :new_successes, :intermittent_failures, :consistent_failures, :missing_tests, :perf_stats, :bc_by_tr, :tc_by_tr

  def initialize(test_run, window_size = 10)
    super
  end

  private

  def perform
    super

    previous_id = (@test_runs.size > 1) ? @test_runs[@test_runs.size - 2].id : 0

    sql = <<SQL
SELECT
    build_configurations.name AS build_configuration_name,
    test_configurations.name AS test_configuration_name,
    groups.name AS group_name,
    test_cases.name AS test_case_name,
    count(case when build_configurations.test_run_id = #{@test_run.id} then 1 else NULL end) AS current_run,
    count(case when build_configurations.test_run_id = #{previous_id} then 1 else NULL end) AS in_last_run,
    count(*) AS total_runs,
    count(case when build_configurations.test_run_id = #{@test_run.id} AND test_cases.result = 'SUCCESS' then 1 else NULL end) AS current_success,
    count(case when test_cases.result = 'SUCCESS' then 1 else NULL end) AS total_successes,
    max(case when build_configurations.test_run_id = #{@test_run.id} then test_cases.id else NULL end) AS test_case_id,
    max(case when build_configurations.test_run_id = #{@test_run.id} then test_cases.result else NULL end) AS test_case_result
FROM test_cases
    LEFT JOIN groups ON test_cases.group_id = groups.id
    LEFT JOIN test_configurations ON groups.test_configuration_id = test_configurations.id
    LEFT JOIN build_configurations ON test_configurations.build_configuration_id = build_configurations.id
WHERE
    build_configurations.test_run_id IN (#{@test_runs.collect {|tr| tr.id}.join(', ')})
GROUP BY build_configuration_name, test_configuration_name, group_name, test_case_name
SQL

    missing_tests_sql = <<SQL
SELECT * FROM (#{sql}) f
WHERE test_case_id IS NULL AND in_last_run = 1
ORDER BY build_configuration_name, test_configuration_name, group_name, test_case_name
SQL

    new_successes_sql = <<SQL
SELECT * FROM (#{sql}) f
WHERE test_case_id IS NOT NULL AND current_success = 1 AND total_successes = 1
ORDER BY build_configuration_name, test_configuration_name, group_name, test_case_name
SQL

    new_failures_sql = <<SQL
SELECT * FROM (#{sql}) f
WHERE test_case_id IS NOT NULL AND current_success = 0 AND total_successes = #{test_runs.size - 1}
ORDER BY build_configuration_name, test_configuration_name, group_name, test_case_name
SQL

    consistent_failures_sql = <<SQL
SELECT * FROM (#{sql}) f
WHERE test_case_id IS NOT NULL AND total_successes = 0
ORDER BY build_configuration_name, test_configuration_name, group_name, test_case_name
SQL

    intermittent_failures_sql = <<SQL
SELECT * FROM (#{sql}) f
WHERE
  test_case_id IS NOT NULL AND
  (
    (current_success != 1 OR total_successes != 1) AND
    (current_success != 0 OR total_successes != #{test_runs.size - 1}) AND
    (total_successes != 0)
  ) AND total_successes != total_runs
ORDER BY build_configuration_name, test_configuration_name, group_name, test_case_name
SQL

    @new_successes = ActiveRecord::Base.connection.select_all(new_successes_sql)
    @new_failures = ActiveRecord::Base.connection.select_all(new_failures_sql)
    @intermittent_failures = ActiveRecord::Base.connection.select_all(intermittent_failures_sql)
    @consistent_failures = ActiveRecord::Base.connection.select_all(consistent_failures_sql)
    @missing_tests = ActiveRecord::Base.connection.select_all(missing_tests_sql)
    @bc_by_tr = gen_x_by_tr('build_configurations.name', 'build_configuration_name')
    @tc_by_tr = gen_x_by_tr('test_cases.name', 'test_case_name')

    stats = [
    'dacapo: antlr', 'dacapo: bloat', 'dacapo: chart', 'dacapo: eclipse',
    'dacapo: fop', 'dacapo: hsqldb', 'dacapo: jython', 'dacapo: luindex',
    'dacapo: lusearch', 'dacapo: pmd', 'dacapo: sunflow', 'dacapo: xalan',
    'SPECjvm98', 'SPECjbb2000', 'SPECjbb2005' ]

    @perf_stats = gen_perf_stats(stats)
  end

end
