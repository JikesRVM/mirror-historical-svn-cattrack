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
class CreateBuildTargets < ActiveRecord::Migration
  def self.up
    create_table :build_targets do |t|
      t.column :name, :string, :limit => 75, :null => false
      t.column :test_run_id, :integer, :null => false
    end
    add_index :build_targets, [:id], :unique => true
    add_index :build_targets, [:test_run_id], :unique => true
    add_index :build_targets, [:test_run_id, :name]
    add_index :build_targets, [:name]
    add_foreign_key :build_targets, [:test_run_id], :test_runs, [:id], :on_delete => :cascade

    create_table :build_target_params, :id => false do |t|
      t.column :owner_id, :integer, :null => false
      t.column :key, :string, :limit => 50, :null => false
      t.column :value, :string, :limit => 256, :null => false
    end
    add_index :build_target_params, [:owner_id, :key], :unique => true
    add_index :build_target_params, [:owner_id]
    add_index :build_target_params, [:owner_id, :key, :value]
    add_foreign_key :build_target_params, [:owner_id], :build_targets, [:id], :on_delete => :cascade

  end

  def self.down
    drop_table :build_target_params
    drop_table :build_targets
  end
end
