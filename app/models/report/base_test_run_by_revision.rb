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
class Report::BaseTestRunByRevision
  # Input parameters
  attr_reader :test_run, :window_size

  # Output parameters
  attr_reader :test_runs

  def initialize(test_run, window_size = 10)
    @test_run = test_run
    @window_size = window_size
    perform
  end

  protected

  def perform
    options = {}
    sql = 'host_id = ? AND start_time <= ? AND variant = ?'
    options[:conditions] = [ sql, @test_run.host.id, @test_run.start_time, @test_run.variant]
    options[:limit] = @window_size
    options[:order] = 'start_time DESC'
    @test_runs = Tdm::TestRun.find(:all, options).reverse
  end

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
    CAST((CAST(count(case when test_case_executions.result = 'SUCCESS' then 1 else NULL end) AS double precision)/count(*) * 100.0) AS int4) as value
  FROM test_case_executions
    LEFT JOIN test_cases ON test_case_executions.test_case_id = test_cases.id
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

  def gen_perf_stats(stats)
    stat_names = if stats
      "IN (#{stats.collect{|s| "'#{s}'"}.join(', ')})"
    else
      "IS NOT NULL"
    end
    filter = <<SQL
  statistics_map.key #{stat_names}
SQL
    best_score_sql = <<SQL
SELECT
    stat_name,
    less_is_more,
    case when less_is_more = true then min_score else max_score end as best_score
FROM (
SELECT
  statistics_map.label as stat_name,
  statistics_map.less_is_more as less_is_more,
  MAX(test_case_statistics.value) as max_score,
  MIN(test_case_statistics.value) as min_score
FROM test_cases
LEFT JOIN test_case_statistics ON test_case_statistics.owner_id = test_cases.id
LEFT JOIN groups ON test_cases.group_id = groups.id
LEFT JOIN test_configurations ON groups.test_configuration_id = test_configurations.id
LEFT JOIN build_configurations ON test_configurations.build_configuration_id = build_configurations.id
LEFT JOIN test_runs ON build_configurations.test_run_id = test_runs.id
LEFT JOIN hosts ON test_runs.host_id = hosts.id
LEFT JOIN statistics_map ON (
  (test_runs.name = statistics_map.test_run_name OR statistics_map.test_run_name IS NULL) AND
  (build_configurations.name = statistics_map.build_configuration_name OR statistics_map.build_configuration_name IS NULL) AND
  (test_configurations.name = statistics_map.test_configuration_name OR statistics_map.test_configuration_name IS NULL) AND
  groups.name = statistics_map.group_name AND
  test_cases.name = statistics_map.test_case_name AND
  test_case_statistics.key = statistics_map.name
  )
WHERE
    hosts.name = '#{@test_run.host.name}' AND
    test_runs.variant = '#{@test_run.variant}' AND
    test_runs.start_time <= '#{@test_run.start_time}' AND
    #{filter}
GROUP BY statistics_map.label, statistics_map.less_is_more
) f
SQL

    results_sql = <<SQL
SELECT
    test_runs.id AS test_run_id,
    statistics_map.label AS stat_name,
    test_case_statistics.value AS value
FROM test_cases
LEFT JOIN test_case_statistics ON test_case_statistics.owner_id = test_cases.id
LEFT JOIN groups ON test_cases.group_id = groups.id
LEFT JOIN test_configurations ON groups.test_configuration_id = test_configurations.id
LEFT JOIN build_configurations ON test_configurations.build_configuration_id = build_configurations.id
LEFT JOIN test_runs ON build_configurations.test_run_id = test_runs.id
LEFT JOIN hosts ON test_runs.host_id = hosts.id
LEFT JOIN statistics_map ON (
  (test_runs.name = statistics_map.test_run_name OR statistics_map.test_run_name IS NULL) AND
  (build_configurations.name = statistics_map.build_configuration_name OR statistics_map.build_configuration_name IS NULL) AND
  (test_configurations.name = statistics_map.test_configuration_name OR statistics_map.test_configuration_name IS NULL) AND
  groups.name = statistics_map.group_name AND
  test_cases.name = statistics_map.test_case_name AND
  test_case_statistics.key = statistics_map.name
  )
WHERE
    test_runs.id IN (#{@test_runs.collect{|tr|tr.id}.join(', ')}) AND
    #{filter}
SQL

    sql = <<SQL
    SELECT
    results.stat_name as name,
    #{rows_to_columns},
    case when less_is_more = true then 1 else 0 end as less_is_more,
    stddev(results.value) AS std_deviation,
    best_score
FROM
  (#{results_sql}) results,
  (#{best_score_sql}) best_scores
WHERE best_scores.stat_name = results.stat_name
GROUP BY results.stat_name, less_is_more, best_score
ORDER BY results.stat_name
SQL
    ActiveRecord::Base.connection.select_all(sql)
  end
end
