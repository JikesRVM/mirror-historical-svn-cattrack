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
class AddEndTimeToTestRuns < ActiveRecord::Migration
  class TestRun < ActiveRecord::Base
  end

  def self.up
    ActiveRecord::Base.transaction do
      rename_table :test_runs, :old_test_runs

      create_table :test_runs do |t|
        t.column :name, :string, :limit => 75, :null => false
        t.column :variant, :string, :limit => 75, :null => false
        t.column :host_id, :integer, :null => false
        t.column :revision, :integer, :null => false
        t.column :start_time, :timestamp, :null => false
        t.column :end_time, :timestamp, :null => false
        t.column :created_at, :timestamp, :null => false
      end

      ActiveRecord::Base.connection.execute(<<SQL)
INSERT INTO test_runs
  SELECT id, name, variant, host_id, revision, start_time, start_time AS end_time, created_at
  FROM old_test_runs
SQL
      drop_table :old_test_runs
      ActiveRecord::Base.connection.reset_pk_sequence!('test_runs')
      add_index :test_runs, [:id], :unique => true
      add_index :test_runs, [:host_id, :name, :start_time], :unique => true
      add_index :test_runs, [:name]
      add_index :test_runs, [:host_id]
      add_index :test_runs, [:revision]
      add_index :test_runs, [:start_time]
      add_foreign_key :test_runs, [:host_id], :hosts, [:id], :on_delete => :cascade, :name => "test_runs_host_id_fkey"

      TestRun.find(:all).each do |tr|
        tr.end_time = tr.start_time + ActiveRecord::Base.connection.select_value(<<SQL).to_i/1000
SELECT SUM(test_case_executions.time)
FROM test_case_executions
LEFT JOIN test_cases ON test_case_executions.test_case_id = test_cases.id
LEFT JOIN groups ON test_cases.group_id = groups.id
LEFT JOIN test_configurations ON groups.test_configuration_id = test_configurations.id
LEFT JOIN test_configuration_params ON test_configurations.id = test_configuration_params.owner_id
LEFT JOIN build_configurations ON test_configurations.build_configuration_id = build_configurations.id
LEFT JOIN test_runs ON build_configurations.test_run_id = test_runs.id
WHERE test_runs.id = #{tr.id}
GROUP by test_runs.id
SQL
        tr.save!
      end
    end
  end

  def self.down
  end
end
