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
class Tdm::TestRun < ActiveRecord::Base
  validates_length_of :name, :in => 1..75
  validates_length_of :variant, :in => 1..75
  validates_uniqueness_of :name, :scope => [:host_id, :occurred_at]
  validates_format_of :name, :with => /^[\-a-zA-Z_0-9]+$/
  validates_format_of :variant, :with => /^[\-a-zA-Z_0-9]+$/
  validates_presence_of :host_id
  validates_reference_exists :host_id, Tdm::Host
  validates_positiveness_of :revision
  validates_numericality_of :revision, :only_integer => true
  validates_presence_of :occurred_at

  belongs_to :host
  has_one :build_target, :dependent => :destroy
  has_many :build_configurations, :order => 'name', :dependent => :destroy

  TEST_RUN_TO_TESTCASE_SQL = <<-END_SQL
   FROM test_runs
   RIGHT JOIN build_configurations ON build_configurations.test_run_id = test_runs.id
   RIGHT JOIN test_configurations ON test_configurations.build_configuration_id = build_configurations.id
   RIGHT JOIN groups ON groups.test_configuration_id = test_configurations.id
   RIGHT JOIN test_cases ON test_cases.group_id = groups.id
   RIGHT JOIN test_case_results ON test_case_results.test_case_id = test_cases.id
  END_SQL
  TESTCASE_SQL_PREFIX =  "SELECT test_case_results.* #{TEST_RUN_TO_TESTCASE_SQL} WHERE test_runs.id = \#{id}"

  def self.test_case_rel(name, sql = nil)
    common_sql = sql.nil? ? TESTCASE_SQL_PREFIX : TESTCASE_SQL_PREFIX + ' AND ' + sql
    finder_sql = common_sql + " ORDER BY build_configurations.name, test_configurations.name, groups.name, test_cases.name"
    counter_sql = "SELECT COUNT(*) FROM (#{common_sql}) f"
    has_many name, :class_name => 'Tdm::TestCaseResult', :finder_sql => finder_sql, :counter_sql => counter_sql
  end

  test_case_rel :successes, "test_case_results.result = 'SUCCESS'"
  test_case_rel :non_successes, "test_case_results.result != 'SUCCESS'"
  test_case_rel :test_case_results

  include TestCaseContainer

  def label
    "#{variant}.#{id}"
  end

  def parent_node
    host
  end
end
