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
class CreateTestCases < ActiveRecord::Migration
  def self.up
    create_table :test_cases, :force => true do |t|
      t.column :group_id, :integer, :null => false, :on_delete => :cascade
      t.column :name, :string, :limit => 75, :null => false
      t.column :classname, :string, :limit => 75, :null => false
      t.column :args, :string, :limit => 256, :null => false
      t.column :working_directory, :string, :limit => 75, :null => false
      t.column :command, :string, :limit => 256, :null => false
      t.column :result, :string, :limit => 15, :null => false
      t.column :result_explanation, :string, :limit => 75, :null => false
      t.column :exit_code, :integer, :null => false
      t.column :time, :integer, :null => false
    end
    add_index :test_cases, [:group_id, :name], :unique => true
    add_index :test_cases, [:name]
    add_index :test_cases, [:result]

    create_table :test_case_outputs, :id => false, :force => true do |t|
      t.column :test_case_id, :integer, :null => false, :on_delete => :cascade
      t.column :output, :text, :null => false
    end
    add_index :test_case_outputs, [:test_case_id], :unique => true

    create_table :test_case_params, :id => false, :force => true do |t|
      t.column :owner_id, :integer, :null => false, :on_delete => :cascade, :references => :test_cases
      t.column :key, :string, :limit => 50, :null => false
      t.column :value, :string, :limit => 50, :null => false
    end
    add_index :test_case_params, [:owner_id, :key], :unique => true
    add_index :test_case_params, [:owner_id]
    add_index :test_case_params, [:owner_id, :key, :value]

    create_table :test_case_statistics, :id => false, :force => true do |t|
      t.column :owner_id, :integer, :null => false, :on_delete => :cascade, :references => :test_cases
      t.column :key, :string, :limit => 50, :null => false
      t.column :value, :string, :limit => 50, :null => false
    end
    add_index :test_case_statistics, [:owner_id, :key], :unique => true
    add_index :test_case_statistics, [:owner_id]
    add_index :test_case_statistics, [:owner_id, :key, :value]
  end

  def self.down
    drop_table :test_case_outputs
    drop_table :test_case_statistics
    drop_table :test_case_params
    drop_table :test_cases
  end
end
