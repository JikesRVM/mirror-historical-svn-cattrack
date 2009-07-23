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
class SeparateTestCaseStatistics < ActiveRecord::Migration
  def self.up
    create_table :test_case_num_stats, :id => false do |t|
      t.column :owner_id, :integer, :null => false
      t.column :key, :string, :limit => 50, :null => false
      t.column :value, :float, :null => false
    end
    add_index :test_case_num_stats, [:owner_id, :key], :unique => true
    add_index :test_case_num_stats, [:owner_id]
    add_index :test_case_num_stats, [:owner_id, :key, :value]
    add_foreign_key :test_case_num_stats, [:owner_id], :test_cases, [:id], :on_delete => :cascade
    ActiveRecord::Base.transaction do
      sql = <<SQL
INSERT INTO test_case_num_stats
 SELECT test_case_statistics.owner_id, test_case_statistics.key, CAST(test_case_statistics.value AS float8) AS value
 FROM test_case_statistics
 WHERE test_case_statistics.value SIMILAR TO '^\\\\d+$|^\\\\d+\\.\\\\d+$'
SQL
      ActiveRecord::Base.connection.execute(sql)
      sql = "DELETE FROM test_case_statistics WHERE test_case_statistics.value SIMILAR TO '^\\\\d+$|^\\\\d+\\\\.\\\\d+$'"
      ActiveRecord::Base.connection.execute(sql)
    end
  end

  def self.down
    drop_table :test_case_num_stats
  end
end
