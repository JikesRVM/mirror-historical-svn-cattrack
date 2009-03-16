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
class Tdm::Group < ActiveRecord::Base
  validates_length_of :name, :in => 1..75
  validates_format_of :name, :with => /^[\-a-zA-Z_0-9\.]+$/
  validates_uniqueness_of :name, :scope => [:test_configuration_id]
  validates_presence_of :test_configuration_id
  validates_reference_exists :test_configuration_id, Tdm::TestConfiguration

  belongs_to :test_configuration

  has_many :test_cases, :order => 'name', :dependent => :destroy

  TESTCASE_SQL_PREFIX = <<-END_SQL
   SELECT test_cases.*
   FROM groups
   RIGHT JOIN test_cases ON test_cases.group_id = groups.id
   RIGHT JOIN test_case_executions ON test_case_executions.test_case_id = test_cases.id
   WHERE groups.id = \#{id}
  END_SQL

  def self.test_case_rel(name,sql = nil)
    common_sql = sql.nil? ? TESTCASE_SQL_PREFIX : TESTCASE_SQL_PREFIX + ' AND ' + sql
    finder_sql = common_sql + " ORDER BY groups.name, test_cases.name"
    counter_sql = "SELECT COUNT(*) FROM (#{common_sql}) f"
    has_many name, :class_name => 'Tdm::TestCaseExecution', :finder_sql => finder_sql, :counter_sql => counter_sql
  end

  test_case_rel :successes, "test_case_executions.result = 'SUCCESS'"
  test_case_rel :test_case_executions

  include TestCaseContainer

  def parent_node
    test_configuration
  end
end
