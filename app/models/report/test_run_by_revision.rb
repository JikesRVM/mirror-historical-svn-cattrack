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
class Report::TestRunByRevision
  # Input parameters
  attr_reader :test_run, :window_size

  # Output parameters
  attr_reader :test_runs, :new_failures, :new_successes, :intermittent_failures, :consistent_failures, :missing_tests, :perf_stats, :bc_by_tr, :tc_by_tr, :success_rates

  def initialize(test_run, window_size = 10)
    @test_run = test_run
    @window_size = window_size
    perform
  end

  private

  def perform
    options = {}
    sql = 'host_id = ? AND occurred_at <= ? AND variant = ?'
    options[:conditions] = [ sql, @test_run.host.id, @test_run.occurred_at, @test_run.variant]
    options[:limit] = @window_size
    options[:order] = 'occurred_at DESC'
    @test_runs = Tdm::TestRun.find(:all, options).reverse

    sql = <<SQL
SELECT
    build_configurations.name AS build_configuration_name,
    test_configurations.name AS test_configuration_name,
    groups.name AS group_name,
    test_cases.name AS test_case_name,
    count(case when build_configurations.test_run_id = #{@test_run.id} then 1 else NULL end) AS current_run,
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
ORDER BY build_configurations.name, test_configurations.name, groups.name, test_cases.name
SQL

    @new_successes = []
    @new_failures = []
    @intermittent_failures = []
    @consistent_failures = []
    @missing_tests = []

    ActiveRecord::Base.connection.select_all(sql).each do |r|
      if r['test_case_id'].nil?
        @missing_tests << r
      elsif r['current_success'] == '1' and r['total_successes'] == '1'
        @new_successes << r
      elsif r['current_success'] == '0' and r['total_successes'] == (test_runs.size - 1).to_s
        @new_failures << r
      elsif r['total_successes'] == '0'
        @consistent_failures << r
      elsif (r['total_successes'] != r['total_runs'])
        @intermittent_failures << r
      end
    end

    @bc_by_tr = gen_x_by_tr('build_configurations.name', 'build_configuration_name')
    @tc_by_tr = gen_x_by_tr('test_cases.name', 'test_case_name')
    @perf_stats = gen_perf_stats
    @success_rates = gen_success_rates
  end

  private

  def rows_to_columns
    columns = @test_runs.collect do |tr|
      "MAX(case when test_run_id = #{tr.id} then value else NULL end) AS test_run_#{tr.id}"
    end.join(', ')
  end

  def gen_x_by_tr(dimension, label)
    sql = <<SQL
SELECT
    #{label},
    #{rows_to_columns}
FROM
  (SELECT
    test_runs.id AS test_run_id,
    #{dimension} AS #{label},
    CAST((CAST(count(case when test_cases.result = 'SUCCESS' then 1 else NULL end) AS double precision)/count(*) * 100.0) AS int4) as value
  FROM test_cases
    LEFT JOIN groups ON test_cases.group_id = groups.id
    LEFT JOIN test_configurations ON groups.test_configuration_id = test_configurations.id
    LEFT JOIN build_configurations ON test_configurations.build_configuration_id = build_configurations.id
    LEFT JOIN test_runs ON build_configurations.test_run_id = test_runs.id
  WHERE test_runs.id IN (#{@test_runs.collect{|tr|tr.id}.join(', ')})
  GROUP BY test_runs.id, #{dimension}) t
GROUP BY #{label}
HAVING SUM(value) < #{@test_runs.size} * 100
ORDER BY SUM(value), #{label}
SQL
    ActiveRecord::Base.connection.select_all(sql)
  end

  def gen_perf_stats
    maxs_filter_criteria = <<SQL
    build_configurations.name = 'production' AND
    test_configurations.name = 'Performance' AND
    (
      (groups.name = 'SPECjbb2005' AND test_case_numerical_statistics.key = 'score') OR
      (groups.name = 'SPECjvm98'  AND test_case_numerical_statistics.key = 'aggregate.best.score')
    )
SQL
    mins_filter_criteria = <<SQL
    build_configurations.name = 'production' AND
    test_configurations.name = 'default' AND
    groups.name = 'dacapo' AND
    test_case_numerical_statistics.key = 'time'
SQL
    filter_criteria = "(#{maxs_filter_criteria}) OR (#{mins_filter_criteria})"

    best_score_sql = <<SQL
SELECT
  test_cases.name as stat_name,
  MAX(test_case_numerical_statistics.value) as max_score,
  MIN(test_case_numerical_statistics.value) as min_score
FROM hosts
RIGHT JOIN test_runs ON test_runs.host_id = hosts.id
RIGHT JOIN build_configurations ON build_configurations.test_run_id = test_runs.id
RIGHT JOIN test_configurations ON test_configurations.build_configuration_id = build_configurations.id
RIGHT JOIN groups ON groups.test_configuration_id = test_configurations.id
RIGHT JOIN test_cases ON test_cases.group_id = groups.id
RIGHT JOIN test_case_numerical_statistics ON test_case_numerical_statistics.owner_id = test_cases.id
WHERE
    hosts.name = '#{@test_run.host.name}' AND
    test_runs.variant = '#{@test_run.variant}' AND
    test_runs.occurred_at <= '#{@test_run.occurred_at}' AND
    #{filter_criteria}
GROUP BY test_cases.name, test_case_numerical_statistics.key
SQL

    results_sql = <<SQL
SELECT
    test_runs.id AS test_run_id,
    groups.name as suite_name,
    test_cases.name AS stat_name,
    test_case_numerical_statistics.value AS value,
    0 AS less_is_more
FROM test_runs
    RIGHT JOIN build_configurations ON build_configurations.test_run_id = test_runs.id
    LEFT JOIN test_configurations ON test_configurations.build_configuration_id = build_configurations.id
    RIGHT JOIN groups ON groups.test_configuration_id = test_configurations.id
    RIGHT JOIN test_cases ON test_cases.group_id = groups.id
    RIGHT JOIN test_case_numerical_statistics ON test_case_numerical_statistics.owner_id = test_cases.id
WHERE
    test_runs.id IN (#{@test_runs.collect{|tr|tr.id}.join(', ')}) AND
    #{maxs_filter_criteria}
UNION
SELECT
    test_runs.id AS test_run_id,
    groups.name as suite_name,
    test_cases.name AS stat_name,
    test_case_numerical_statistics.value AS value,
    1 AS less_is_more
FROM test_runs
    RIGHT JOIN build_configurations ON build_configurations.test_run_id = test_runs.id
    LEFT JOIN test_configurations ON test_configurations.build_configuration_id = build_configurations.id
    RIGHT JOIN groups ON groups.test_configuration_id = test_configurations.id
    RIGHT JOIN test_cases ON test_cases.group_id = groups.id
    RIGHT JOIN test_case_numerical_statistics ON test_case_numerical_statistics.owner_id = test_cases.id
WHERE
    test_runs.id IN (#{@test_runs.collect{|tr|tr.id}.join(', ')}) AND
    #{mins_filter_criteria}
SQL

    sql = <<SQL
    SELECT
    results.stat_name as name,
    #{rows_to_columns},
    results.less_is_more as less_is_more,
    stddev(results.value) AS std_deviation,
    max(case when results.less_is_more = 1 then min_score else max_score end) as best_score
FROM
  (#{results_sql}) results,
  (#{best_score_sql}) best_scores
WHERE best_scores.stat_name = results.stat_name
GROUP BY results.suite_name, results.stat_name, results.less_is_more
ORDER BY results.suite_name, results.stat_name
SQL
    ActiveRecord::Base.connection.select_all(sql)
  end

  def gen_success_rates
    @test_runs.collect {|tr| "#{tr.successes.size}/#{tr.test_cases.size}"}
  end
end
