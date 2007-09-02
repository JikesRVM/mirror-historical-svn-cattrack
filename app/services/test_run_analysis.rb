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

# Utility class for building TestRun from an xml file.
class TestRunAnalysis
  cattr_accessor :logger

  def self.perform_full_analysis
    Tdm::TestRun.find(:all).each do |test_run|
      perform_analysis(test_run)
    end
  end

  def self.perform_analysis(test_run)
    logger.debug( "Performing analysis on '#{test_run.label}'")
    remove_statistics(test_run)
    perform_statistic_gathering(test_run)
  end

  private

  def self.remove_statistics(test_run)
    ActiveRecord::Base.connection.execute(<<SQL)
    DELETE FROM test_case_statistics WHERE owner_id IN (
SELECT test_cases.id
FROM test_cases
LEFT JOIN groups ON test_cases.group_id = groups.id
LEFT JOIN test_configurations ON groups.test_configuration_id = test_configurations.id
LEFT JOIN build_configurations ON test_configurations.build_configuration_id = build_configurations.id
LEFT JOIN test_runs ON build_configurations.test_run_id = test_runs.id
WHERE test_runs.id = #{test_run.id}
)
SQL
  end

  def self.perform_statistic_gathering(test_run)
    values = ActiveRecord::Base.connection.select_all(<<SQL)
SELECT
  test_cases.id AS test_case_id,
  statistics_map.name AS name,
  statistics_map.statistic_key AS statistic_key,
  statistics_map.statistic_function AS statistic_function
FROM test_case_execution_numerical_statistics
LEFT JOIN test_case_executions ON test_case_execution_numerical_statistics.owner_id = test_case_executions.id
LEFT JOIN test_cases ON test_case_executions.test_case_id = test_cases.id
LEFT JOIN groups ON test_cases.group_id = groups.id
LEFT JOIN test_configurations ON groups.test_configuration_id = test_configurations.id
LEFT JOIN build_configurations ON test_configurations.build_configuration_id = build_configurations.id
LEFT JOIN test_runs ON build_configurations.test_run_id = test_runs.id
LEFT JOIN statistics_map ON (
  (test_runs.name = statistics_map.test_run_name OR statistics_map.test_run_name IS NULL) AND
  (build_configurations.name = statistics_map.build_configuration_name OR statistics_map.build_configuration_name IS NULL) AND
  (test_configurations.name = statistics_map.test_configuration_name OR statistics_map.test_configuration_name IS NULL) AND
  groups.name = statistics_map.group_name AND
  test_cases.name = statistics_map.test_case_name AND
  test_case_execution_numerical_statistics.key = statistics_map.statistic_key
  )
WHERE
  test_runs.id = '#{test_run.id}' AND statistics_map.statistic_key IS NOT NULL
SQL
    values.each do |r|
      f = r['statistic_function']
      logger.debug( "Performing '#{f}' for test_case #{r['test_case_id']} on statistic #{r['statistic_key']}")
      if 'average' == f
        do_average(r['test_case_id'], r['statistic_key'], r['name'])
      else
        raise "Unknown function for statistic: #{f}"
      end
    end
  end

  def self.do_average(test_case_id, statistic_key, name)
    value = ActiveRecord::Base.connection.select_value(<<SQL)
    SELECT AVG(value)
    FROM test_case_execution_numerical_statistics
    LEFT JOIN test_case_executions ON test_case_execution_numerical_statistics.owner_id = test_case_executions.id
    WHERE
      test_case_id = #{test_case_id} AND
      key = '#{statistic_key}' AND
      result = 'SUCCESS'
SQL
    if value
      test_case = Tdm::TestCase.find(test_case_id)
      test_case.statistics[name] = value
      test_case.save!
    end
  end
end