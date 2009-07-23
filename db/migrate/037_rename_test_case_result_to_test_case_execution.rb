#
#  This file is part of the Jikes RVM project (http://jikesrvm.org).
#
#  This file is licensed to You under the Eclipse Public License (EPL);
#  You may not use this file except in compliance with the License. You
#  may obtain a copy of the License at
#
#      http://www.opensource.org/licenses/cpl1.0.php
#
#  See the COPYRIGHT.txt file distributed with this work for information
#  regarding copyright ownership.
#
class RenameTestCaseResultToTestCaseExecution < ActiveRecord::Migration
  def self.up
    rename_table :test_case_results, :test_case_executions
    rename_table :test_case_result_outputs, :test_case_execution_outputs
    rename_table :test_case_result_statistics, :test_case_execution_statistics
    rename_table :test_case_result_num_stats, :test_case_execution_num_stats
  end
  def self.down
  end
end
