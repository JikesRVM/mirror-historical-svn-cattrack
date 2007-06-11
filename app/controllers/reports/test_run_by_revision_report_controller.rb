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
class Reports::TestRunByRevisionReportController < ApplicationController
  verify :method => :get, :redirect_to => :access_denied_url
  caches_page :show
  session :off

  def show
    @host = Host.find_by_name(params[:host_name])
    @test_run = @host.test_runs.find_by_id_and_name(params[:test_run_id], params[:test_run_name])

    options = {}
    options[:conditions] =
    ['host_id = ? AND occured_at < ? AND name = ? AND id != ?', @host.id, @test_run.occured_at, @test_run.name, @test_run.id ]
    options[:limit] = 10
    options[:order] = 'occured_at DESC'
    @test_runs = TestRun.find(:all, options)
    @test_run_ids = @test_runs.collect {|tr| tr.id}

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
            test_count = count(@test_run.id,@test_run_ids, bc.name, tc.name, g.name, t.name)
            success_count = count(@test_run.id,@test_run_ids, bc.name, tc.name, g.name, t.name, "test_cases.result = 'SUCCESS'")
            if (success and success_count == 0)
              @new_successes << t
            elsif (not success and success_count == test_count)
              @new_failures << t
            elsif (not success and success_count == 0)
              @consistent_failures << t
            elsif (not success)
              @intermittent_failures << t
            end
          end
        end
      end
    end
    @results = [ 'new_failures', 'new_successes', 'intermittent_failures', 'consistent_failures' ].collect do |name|
      [name.humanize.titleize, instance_variable_get("@#{name}")]
    end
  end

  private

  def count(test_run_id, test_run_ids, build_configuration_name, test_configuration_name, group_name, test_case_name, extra = '1 = 1')
    options = {}
    options[:test_run_id] = test_run_id
    options[:build_configuration_name] = build_configuration_name
    options[:test_configuration_name] = test_configuration_name
    options[:group_name] = group_name
    options[:test_case_name] = test_case_name

    conditions = <<-SQL
  test_runs.id != :test_run_id AND
  build_configurations.name = :build_configuration_name AND
  test_configurations.name = :test_configuration_name AND
  groups.name = :group_name AND
  test_cases.name = :test_case_name AND
  #{extra}
SQL

    if test_run_ids.size > 0
      options[:test_run_ids] = test_run_ids
      conditions << ' AND test_runs.id IN (:test_run_ids)'
    end

    criteria = ActiveRecord::Base.send :sanitize_sql_array, [conditions, options]
    sql = "SELECT count(*) #{TestRun::TEST_RUN_TO_TESTCASE_SQL} WHERE #{criteria}"
    TestRun.connection.select_value(sql).to_i
  end
end
