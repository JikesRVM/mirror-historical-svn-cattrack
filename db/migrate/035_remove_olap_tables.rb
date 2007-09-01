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
class RemoveOlapTables < ActiveRecord::Migration
  def self.up
    sql = "DELETE FROM audit_logs WHERE name LIKE 'report.%' OR name LIKE 'filter.%' OR name LIKE 'query.%'"
    ActiveRecord::Base.connection.execute(sql)
    drop_table :reports
    drop_table :queries
    drop_table :measures_presentations
    drop_table :measures
    drop_table :presentations
    drop_table :filter_params
    drop_table :filters
    drop_table :statistic_facts
    drop_table :result_facts
    drop_table :test_run_dimension
    drop_table :statistic_dimension
    drop_table :revision_dimension
    drop_table :time_dimension
    drop_table :test_case_dimension
    drop_table :test_configuration_dimension
    drop_table :build_target_dimension
    drop_table :build_configuration_dimension
    drop_table :host_dimension
    drop_table :result_dimension
  end

  def self.down
  end
end
