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
class TestRun < ActiveRecord::Base
  has_many :build_runs, :through => :test_configurations, :uniq => true, :dependent => :destroy

  TESTCASE_SQL_PREFIX = <<-END_SQL
   SELECT
     test_cases.*,
     test_configurations.name AS test_configuration_name,
     test_configurations.id AS test_configuration_id,
     groups.name AS group_name,
     build_configurations.name AS build_configuration_name,
     build_configurations.id AS build_configuration_id
   FROM test_runs
   LEFT OUTER JOIN test_configurations ON test_configurations.test_run_id = test_runs.id
   LEFT OUTER JOIN build_runs ON build_runs.id = test_configurations.build_run_id
   LEFT OUTER JOIN build_configurations ON build_configurations.id = build_runs.build_configuration_id
   LEFT OUTER JOIN groups ON groups.test_configuration_id = test_configurations.id
   LEFT OUTER JOIN test_cases ON test_cases.group_id = groups.id
   WHERE test_runs.id = \#{id}
  END_SQL

  def self.test_case_rel(name,sql = nil)
    common_sql = sql.nil? ? TESTCASE_SQL_PREFIX : TESTCASE_SQL_PREFIX + ' AND ' + sql
    finder_sql = common_sql
    counter_sql = "SELECT COUNT(*) FROM (#{common_sql}) f"
    has_many name, :class_name => 'TestCase', :finder_sql => finder_sql, :counter_sql => counter_sql
  end

  test_case_rel :successes, "test_cases.result = 'SUCCESS'"
  test_case_rel :failures, "test_cases.result = 'FAILURE'"
  test_case_rel :excludes, "test_cases.result = 'EXCLUDE'"
  test_case_rel :test_cases

  validates_positive :revision
end
