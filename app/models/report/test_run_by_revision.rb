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
  attr_reader :test_runs, :new_failures, :new_successes, :intermittent_failures, :consistent_failures, :missing_tests, :perf_stats, :perf_stat_headers, :bc_by_tr, :tc_by_tr

  def initialize(test_run, window_size = 6)
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
    @test_runs = Tdm::TestRun.find(:all, options)
    valid_test_run_ids = @test_runs.collect {|tr| tr.id}

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
FROM build_configurations
    LEFT JOIN test_configurations ON test_configurations.build_configuration_id = build_configurations.id
    LEFT JOIN groups ON groups.test_configuration_id = test_configurations.id
    LEFT JOIN test_cases ON test_cases.group_id = groups.id
WHERE
    build_configurations.test_run_id IN (#{valid_test_run_ids.join(', ')})
GROUP BY build_configuration_name, test_configuration_name, group_name, test_case_name
ORDER BY build_configurations.name, test_configurations.name, groups.name, test_cases.name
SQL
    #HAVING count(case when test_cases.result = 'SUCCESS' then 1 else NULL end) != count(*)

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

    gen_bc_by_tr(valid_test_run_ids)
    gen_tc_by_tr
    gen_perf_stats(valid_test_run_ids)
  end

  private

  def gen_bc_by_tr(valid_test_run_ids)
    columns = valid_test_run_ids.collect do |id|
      "MAX(case when test_run_id = #{id} then success_rate else 0 end) AS test_run_#{id}"
    end.join(', ')
    sql = <<SQL
SELECT
    build_configuration_name,
    #{columns}
FROM
  (SELECT
    test_runs.id AS test_run_id,
    build_configurations.name AS build_configuration_name,
    CAST((CAST(count(case when test_cases.result = 'SUCCESS' then 1 else NULL end) AS double precision)/count(*) * 100.0) AS int4) as success_rate
  FROM test_cases
    RIGHT JOIN groups ON test_cases.group_id = groups.id
    RIGHT JOIN test_configurations ON groups.test_configuration_id = test_configurations.id
    RIGHT JOIN build_configurations ON test_configurations.build_configuration_id = build_configurations.id
    LEFT JOIN test_runs ON build_configurations.test_run_id = test_runs.id
  WHERE test_runs.id IN (#{valid_test_run_ids.join(', ')})
  GROUP BY test_runs.id, build_configurations.name) t
GROUP BY build_configuration_name
HAVING SUM(success_rate) < #{@test_runs.size} * 100
ORDER BY SUM(success_rate), build_configuration_name
SQL
    @bc_by_tr = ActiveRecord::Base.connection.select_all(sql)
  end

  def gen_tc_by_tr
    columns = @test_runs.collect do |tr|
      "MAX(case when test_run_id = #{tr.id} then success_rate else 0 end) AS test_run_#{tr.id}"
    end.join(', ')
    sql = <<SQL
SELECT
    test_case_name,
    #{columns}
FROM
  (SELECT
    test_runs.id AS test_run_id,
    test_cases.name AS test_case_name,
    CAST((CAST(count(case when test_cases.result = 'SUCCESS' then 1 else NULL end) AS double precision)/count(*) * 100.0) AS int4) as success_rate
  FROM test_cases
    RIGHT JOIN groups ON test_cases.group_id = groups.id
    RIGHT JOIN test_configurations ON groups.test_configuration_id = test_configurations.id
    RIGHT JOIN build_configurations ON test_configurations.build_configuration_id = build_configurations.id
    LEFT JOIN test_runs ON build_configurations.test_run_id = test_runs.id
  WHERE test_runs.id IN (#{@test_runs.collect{|tr|tr.id}.join(', ')})
  GROUP BY test_runs.id, test_cases.name) t
GROUP BY test_case_name
HAVING SUM(success_rate) < #{@test_runs.size} * 100
ORDER BY SUM(success_rate), test_case_name
SQL
    @tc_by_tr = ActiveRecord::Base.connection.select_all(sql)
  end


  def gen_perf_stats(valid_test_run_ids)
    query = Olap::Query::Query.new
    query.filter = Olap::Query::Filter.new
    query.filter.name = '*'
    query.filter.description = ''
    query.filter.test_run_source_id = valid_test_run_ids
    query.filter.test_configuration_name = 'Performance'
    query.filter.build_configuration_name = 'production'
    query.filter.query_type = 'statistic'
    query.filter.test_case_name = ['SPECjbb2005', 'SPECjvm98']
    query.filter.statistic_name = ['aggregate.best.score', 'score']
    query.primary_dimension = 'statistic_name'
    query.secondary_dimension = 'test_run_source_id'
    query.measure = Olap::Query::Measure.find_by_name('Maximum')
    #order by occurred_at
    query_result = query.perform_search

    column_count = query_result.column_headers.size
    @perf_stats = []

    test_runs = @test_runs.reverse

    @perf_stats[0] = []
    @perf_stats[0][0] = 'Success Rate'
    if query_result.column_headers.size > 0
      query_result.column_headers.each_with_index do |c, i|
        test_run = @test_runs.detect {|tr| tr.id.to_s == c.to_s}
        @perf_stats[0][i + 1] = "#{test_run.successes.size}/#{test_run.test_cases.size}"
      end
    else
      (0..(test_runs.size-1)).each do |i|
        @perf_stats[0][i + 1] = "#{test_runs[i].successes.size}/#{test_runs[i].test_cases.size}"
      end
    end

    query_result.tabular_data.each_with_index do |row, i|
      @perf_stats[i + 1] = []
      if query_result.row_headers[i] == 'aggregate.best.score'
        @perf_stats[i + 1][0] = 'SPECjvm98'
      else
        @perf_stats[i + 1][0] = 'SPECjbb2005'
      end
      row.each_with_index do |value, j|
        @perf_stats[i + 1][1 + j] = value
      end
    end

    @perf_stats = @perf_stats.reject{|row| row.inject(0) {|accum, e| e.nil? ? accum : accum + 1} == 0}
    @perf_stat_headers = []

    @perf_stat_headers[0] = nil
    if query_result.column_headers.size > 0
      query_result.column_headers.each_with_index do |c, i|
        test_run = @test_runs.detect {|tr| tr.id.to_s == c.to_s}
        raise "Missing #{c} in #{@test_runs.collect{|tr|tr.id}.join(',')}" unless test_run
        @perf_stat_headers[i + 1] = test_run.label
      end
    else
      (0..(test_runs.size-1)).each do |i|
        @perf_stat_headers[i + 1] = test_runs[i].label
      end
    end
  end
end
