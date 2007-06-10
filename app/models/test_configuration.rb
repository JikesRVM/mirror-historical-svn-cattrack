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
class TestConfiguration < ActiveRecord::Base
  belongs_to :build_configuration
  has_many :groups, :dependent => :destroy
  has_params :params

  TESTCASE_SQL_PREFIX = <<-END_SQL
   SELECT test_cases.*
   FROM test_configurations
   LEFT OUTER JOIN groups ON groups.test_configuration_id = test_configurations.id
   LEFT OUTER JOIN test_cases ON test_cases.group_id = groups.id
   WHERE test_configurations.id = \#{id}
  END_SQL

  def self.test_case_rel(name,sql = nil)
    common_sql = sql.nil? ? TESTCASE_SQL_PREFIX : TESTCASE_SQL_PREFIX + ' AND ' + sql
    finder_sql = common_sql
    counter_sql = "SELECT COUNT(*) FROM (#{common_sql}) f"
    has_many name, :class_name => 'TestCase', :finder_sql => finder_sql, :counter_sql => counter_sql
  end

  test_case_rel :successes, "test_cases.result = 'SUCCESS'"
  test_case_rel :excluded, "test_cases.result = 'EXCLUDED'"
  test_case_rel :test_cases

  include TestCaseContainer

  def parent_node
    build_configuration.test_run
  end
end
