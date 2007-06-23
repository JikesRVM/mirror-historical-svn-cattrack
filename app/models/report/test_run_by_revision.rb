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
  attr_reader :test_runs, :new_failures, :new_successes, :intermittent_failures, :consistent_failures, :build_configuration_name_by_test_run, :tcn_by_tr_headers, :tcn_by_tr, :perf_stats, :perf_stat_headers

  def initialize(test_run, window_size = 6)
    @test_run = test_run
    @window_size = window_size
    perform
  end

  private

  def perform
    options = {}
    sql = 'host_id = ? AND occurred_at < ? AND name = ? AND id != ?'
    options[:conditions] = [ sql, @test_run.host.id, @test_run.occurred_at, @test_run.name, @test_run.id ]
    options[:limit] = @window_size
    options[:order] = 'occurred_at DESC'
    @past_test_runs = Tdm::TestRun.find(:all, options)
    test_run_ids = @past_test_runs.collect {|tr| tr.id}

    @new_failures = []
    @new_successes = []
    @intermittent_failures = []
    @consistent_failures = []

    @test_run.build_configurations.each do |bc|
      bc.test_configurations.each do |tc|
        tc.build_configuration = bc # Avoid loads when rendering
        tc.groups.each do |g|
          g.test_configuration = tc # Avoid loads when rendering
          g.test_cases.each do |t|
            t.group = g # Avoid loads when rendering
            success = t.result == 'SUCCESS'
            test_count, success_count = count(test_run_ids, bc.name, tc.name, g.name, t.name)
            #puts "#{bc.name}.#{tc.name}.#{g.name}.#{t.name} success=#{success}, test_count=#{test_count}, success_count=#{success_count} #{t.id}.result=#{t.result}"
            if (success and success_count == 0)
              @new_successes << t
            elsif (not success and success_count == test_count)
              @new_failures << t
            elsif (not success and success_count == 0)
              @consistent_failures << t
            elsif (success_count != test_count)
              @intermittent_failures << t
            end
          end
        end
      end
    end

    @test_runs = [@test_run] + @past_test_runs
    valid_test_runs_ids = @test_runs.collect {|tr| tr.id}

    query = Olap::Query::Query.new
    query.filter = Olap::Query::Filter.new
    query.filter.name = '*'
    query.filter.description = ''
    query.filter.test_run_source_id = valid_test_runs_ids
    query.primary_dimension = 'build_configuration_name'
    query.secondary_dimension = 'test_run_source_id'
    query.measure = Olap::Query::Measure.find_by_name('Success Rate')
    #order by occurred_at
    @build_configuration_name_by_test_run = query.perform_search

    gen_perf_stats(valid_test_runs_ids)
    perform_test_case_name_by_test_run(valid_test_runs_ids)
  end

  private

  def gen_perf_stats(valid_test_runs_ids)
    query = Olap::Query::Query.new
    query.filter = Olap::Query::Filter.new
    query.filter.name = '*'
    query.filter.description = ''
    query.filter.test_run_source_id = valid_test_runs_ids
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
    query_result.tabular_data.each_with_index do |row, i|
      @perf_stats[i] = []
      if query_result.row_headers[i] == 'aggregate.best.score'
        @perf_stats[i][0] = 'SPECjvm98'
      else
        @perf_stats[i][0] = 'SPECjbb2005'
      end
      row.each_with_index do |value, j|
        @perf_stats[i][1 + j] = value
      end
    end

    @perf_stats = @perf_stats.reject{|row| row.inject(0) {|accum, e| e.nil? ? accum : accum + 1} == 0}
    @perf_stat_headers = []

    @perf_stat_headers[0] = nil
    query_result.column_headers.each_with_index do |c, i|
      test_run = @test_runs.detect {|tr| tr.id.to_s == c.to_s}
      raise "Missing #{c} in #{@test_runs.collect{|tr|tr.id}.join(',')}" unless test_run
      @perf_stat_headers[i + 1] = test_run.label
    end
  end

  def perform_test_case_name_by_test_run(valid_test_runs_ids)
    query = Olap::Query::Query.new
    query.filter = Olap::Query::Filter.new
    query.filter.name = '*'
    query.filter.description = ''
    query.filter.test_run_source_id = valid_test_runs_ids
    query.primary_dimension = 'test_case_name'
    query.secondary_dimension = 'test_run_source_id'
    query.measure = Olap::Query::Measure.find_by_name('Success Rate')

    @test_case_name_by_test_run = query.perform_search

    column_count = @test_case_name_by_test_run.column_headers.size
    @tcn_by_tr = []
    @test_case_name_by_test_run.tabular_data.each_with_index do |row, i|
      @tcn_by_tr[i] = []
      @tcn_by_tr[i][column_count + 1] = row.inject(0.0) {| memo, value | memo + value.to_f }.to_i
      row.each_with_index do |value, j|
        @tcn_by_tr[i][1 + j] = value
      end
      @tcn_by_tr[i][0] = @test_case_name_by_test_run.row_headers[i]
    end

    column_count = @test_case_name_by_test_run.column_headers.size
    max_value = @test_case_name_by_test_run.column_headers.size * 100
    @tcn_by_tr = @tcn_by_tr.reject{|row| row[column_count + 1] == max_value}
    @tcn_by_tr = @tcn_by_tr.sort_by{|row| row[column_count + 1]}
    @tcn_by_tr_headers = []

    @tcn_by_tr_headers[0] = nil
    @test_case_name_by_test_run.column_headers.each_with_index do |c, i|
      test_run = @test_runs.detect {|tr| tr.id.to_s == c.to_s}
      raise "Missing #{c} in #{@test_runs.collect{|tr|tr.id}.join(',')}" unless test_run
      @tcn_by_tr_headers[i + 1] = test_run.label
    end
  end

  def count(test_run_ids, build_configuration_name, test_configuration_name, group_name, test_case_name)
    options = {}
    options[:test_run_id] = @test_run.id
    options[:test_run_name] = @test_run.name
    options[:build_configuration_name] = build_configuration_name
    options[:test_configuration_name] = test_configuration_name
    options[:group_name] = group_name
    options[:test_case_name] = test_case_name
    if test_run_ids.size > 0
      options[:test_run_ids] = test_run_ids
      extra = 'AND test_runs.id IN (:test_run_ids)'
    else
      extra = ''
    end

    sql = <<-SQL
SELECT
  count(*) AS test_count,
  count(case when test_cases.result = 'SUCCESS' then 1 else NULL end) AS success_count
#{Tdm::TestRun::TEST_RUN_TO_TESTCASE_SQL} WHERE
  test_runs.name = :test_run_name AND
  test_runs.id != :test_run_id AND
  build_configurations.name = :build_configuration_name AND
  test_configurations.name = :test_configuration_name AND
  groups.name = :group_name AND
  test_cases.name = :test_case_name #{extra}
SQL
    sql = ActiveRecord::Base.send :sanitize_sql_array, [sql, options]
    values = Tdm::TestRun.connection.select_one(sql)
    #puts "values=#{values.inspect}"
    return values['test_count'].to_i, values['success_count'].to_i
  end

end
