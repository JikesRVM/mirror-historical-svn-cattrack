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
class CreateTestCaseResults < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      create_table :test_case_results do |t|
        t.column :name, :string, :limit => 75, :null => false
        t.column :test_case_id, :integer, :null => false
        t.column :result, :string, :limit => 15, :null => false
        t.column :result_explanation, :string, :limit => 256, :null => false
        t.column :exit_code, :integer, :null => false
        t.column :time, :integer, :null => false
      end
      add_index :test_case_results, [:id], :unique => true
      add_index :test_case_results, [:test_case_id, :name], :unique => true
      add_index :test_case_results, [:name]
      add_index :test_case_results, [:result]
      add_foreign_key :test_case_results, [:test_case_id], :test_cases, [:id], :on_delete => :cascade

      ActiveRecord::Base.connection.execute(<<SQL)
INSERT INTO test_case_results
  SELECT id, 'default' AS name, id AS test_case_id, result, result_explanation, exit_code, time
  FROM test_cases
SQL
      remove_column :test_cases, :result
      remove_column :test_cases, :result_explanation
      remove_column :test_cases, :exit_code
      remove_column :test_cases, :time
      ActiveRecord::Base.connection.execute("SELECT setval('test_case_results_id_seq', 715874)")

      # Copy old output to new table linking to results
      create_table :test_case_result_outputs, :id => false do |t|
        t.column :owner_id, :integer, :null => false
        t.column :output, :text, :null => false
      end

      ActiveRecord::Base.connection.execute(<<SQL)
INSERT INTO test_case_result_outputs
  SELECT
    test_case_id AS owner_id, output
  FROM test_case_outputs
SQL
      drop_table :test_case_outputs
      add_index :test_case_result_outputs, [:owner_id], :unique => true
      add_foreign_key :test_case_result_outputs, [:owner_id], :test_case_results, [:id], :on_delete => :cascade

      # Copy old statistics to new table linking to results
      create_table :test_case_result_statistics, :id => false do |t|
        t.column :owner_id, :integer, :null => false
        t.column :key, :string, :limit => 50, :null => false
        t.column :value, :string, :limit => 256, :null => false
      end

      ActiveRecord::Base.connection.execute(<<SQL)
INSERT INTO test_case_result_statistics
  SELECT owner_id, key, value
  FROM test_case_statistics
SQL
      drop_table :test_case_statistics
      add_index :test_case_result_statistics, [:owner_id, :key], :unique => true
      add_index :test_case_result_statistics, [:owner_id]
      add_index :test_case_result_statistics, [:owner_id, :key, :value]
      add_foreign_key :test_case_result_statistics, [:owner_id], :test_case_results, [:id], :on_delete => :cascade

      # Copy old numerical statistics to new table linking to results
      create_table :test_case_result_numerical_statistics, :id => false do |t|
        t.column :owner_id, :integer, :null => false
        t.column :key, :string, :limit => 50, :null => false
        t.column :value, :float, :null => false
      end

      ActiveRecord::Base.connection.execute(<<SQL)
INSERT INTO test_case_result_numerical_statistics
  SELECT owner_id, key, value
  FROM test_case_numerical_statistics
SQL
      drop_table :test_case_numerical_statistics
      add_index :test_case_result_numerical_statistics, [:owner_id, :key], :unique => true
      add_index :test_case_result_numerical_statistics, [:owner_id]
      add_index :test_case_result_numerical_statistics, [:owner_id, :key, :value]
      add_foreign_key :test_case_result_numerical_statistics, [:owner_id], :test_case_results, [:id], :on_delete => :cascade
    end
  end

  def self.down
    drop_table :test_case_results
  end
end
