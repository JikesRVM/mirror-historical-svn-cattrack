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
class Report::RunComparisionReport

  # Input parameters
  attr_reader :first_run, :second_run

  # Output parameters
  attr_reader :first_only_pass, :second_only_pass, :both_pass, :neither_pass, :only_in_first, :only_in_second 

  def initialize(first_run, second_run)
    @first_run = first_run
    @second_run = second_run
    perform unless first_run.nil? || second_run.nil?
  end

  def perform
    sql = <<SQL
SELECT
    build_configurations.name AS build_configuration_name,
    test_configurations.name AS test_configuration_name,
    groups.name AS group_name,
    test_cases.name AS test_case_name,
    test_case_executions.name AS test_case_execution_name,
    count(case when build_configurations.test_run_id = #{@first_run.id} then 1 else NULL end) AS in_first_run,
    count(case when build_configurations.test_run_id = #{@second_run.id} then 1 else NULL end) AS in_second_run,
    count(case when build_configurations.test_run_id = #{@first_run.id} AND test_case_executions.result = 'SUCCESS' then 1 else NULL end) AS first_run_success,
    count(case when build_configurations.test_run_id = #{@second_run.id} AND test_case_executions.result = 'SUCCESS' then 1 else NULL end) AS second_run_success
FROM test_case_executions
    LEFT JOIN test_cases ON test_case_executions.test_case_id = test_cases.id
    LEFT JOIN groups ON test_cases.group_id = groups.id
    LEFT JOIN test_configurations ON groups.test_configuration_id = test_configurations.id
    LEFT JOIN build_configurations ON test_configurations.build_configuration_id = build_configurations.id
WHERE
    build_configurations.test_run_id IN (#{@first_run.id}, #{@second_run.id})
GROUP BY build_configuration_name, test_configuration_name, group_name, test_case_name, test_case_execution_name
SQL

    first_only_pass_sql = <<SQL
SELECT * FROM (#{sql}) f
WHERE first_run_success = 1 AND second_run_success != 1
ORDER BY build_configuration_name, test_configuration_name, group_name, test_case_name, test_case_execution_name
SQL

    second_only_pass_sql = <<SQL
SELECT * FROM (#{sql}) f
WHERE first_run_success != 1 AND second_run_success = 1
ORDER BY build_configuration_name, test_configuration_name, group_name, test_case_name, test_case_execution_name
SQL

    both_pass_sql = <<SQL
SELECT * FROM (#{sql}) f
WHERE first_run_success = 1 AND second_run_success = 1
ORDER BY build_configuration_name, test_configuration_name, group_name, test_case_name, test_case_execution_name
SQL

    neither_pass_sql = <<SQL
SELECT * FROM (#{sql}) f
WHERE first_run_success != 1 AND second_run_success != 1
ORDER BY build_configuration_name, test_configuration_name, group_name, test_case_name, test_case_execution_name
SQL

    only_in_first_sql = <<SQL
SELECT * FROM (#{sql}) f
WHERE in_first_run = 1 AND in_second_run != 1
ORDER BY build_configuration_name, test_configuration_name, group_name, test_case_name, test_case_execution_name
SQL

    only_in_second_sql = <<SQL
SELECT * FROM (#{sql}) f
WHERE in_first_run != 1 AND in_second_run = 1
ORDER BY build_configuration_name, test_configuration_name, group_name, test_case_name, test_case_execution_name
SQL

    @first_only_pass = ActiveRecord::Base.connection.select_all(first_only_pass_sql)
    @second_only_pass = ActiveRecord::Base.connection.select_all(second_only_pass_sql)
    @both_pass = ActiveRecord::Base.connection.select_all(both_pass_sql)
    @neither_pass = ActiveRecord::Base.connection.select_all(neither_pass_sql)
    @only_in_first = ActiveRecord::Base.connection.select_all(only_in_first_sql)
    @only_in_second = ActiveRecord::Base.connection.select_all(only_in_second_sql)
    
  end

end
