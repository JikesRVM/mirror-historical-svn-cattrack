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
class CreateStatisticFacts < ActiveRecord::Migration
  def self.up
    create_table :statistic_facts do |t|
      t.column :host_id, :integer, :null => false
      t.column :test_run_id, :integer, :null => false
      t.column :test_configuration_id, :integer, :null => false
      t.column :build_configuration_id, :integer, :null => false
      t.column :build_target_id, :integer, :null => false
      t.column :test_case_id, :integer, :null => false
      t.column :time_id, :integer, :null => false
      t.column :revision_id, :integer, :null => false
      t.column :statistic_id, :integer, :null => false
      t.column :source_id, :integer, :null => true

      t.column :value, :float, :null => false
    end
    add_index :statistic_facts, [:host_id]
    add_index :statistic_facts, [:test_run_id]
    add_index :statistic_facts, [:test_configuration_id]
    add_index :statistic_facts, [:build_configuration_id]
    add_index :statistic_facts, [:build_target_id]
    add_index :statistic_facts, [:test_case_id]
    add_index :statistic_facts, [:time_id]
    add_index :statistic_facts, [:revision_id]
    add_index :statistic_facts, [:source_id]
    add_index :statistic_facts, [:statistic_id]

    add_foreign_key :statistic_facts, [:host_id], :host_dimensions, [:id], :on_delete => :restrict
    add_foreign_key :statistic_facts, [:test_run_id], :test_run_dimensions, [:id], :on_delete => :restrict
    add_foreign_key :statistic_facts, [:test_configuration_id], :test_configuration_dimensions, [:id], :on_delete => :restrict
    add_foreign_key :statistic_facts, [:build_configuration_id], :build_configuration_dimensions, [:id], :on_delete => :restrict
    add_foreign_key :statistic_facts, [:build_target_id], :build_target_dimensions, [:id], :on_delete => :restrict
    add_foreign_key :statistic_facts, [:test_case_id], :test_case_dimensions, [:id], :on_delete => :restrict
    add_foreign_key :statistic_facts, [:time_id], :time_dimensions, [:id], :on_delete => :restrict
    add_foreign_key :statistic_facts, [:revision_id], :revision_dimensions, [:id], :on_delete => :restrict
    add_foreign_key :statistic_facts, [:statistic_id], :statistic_dimensions, [:id], :on_delete => :restrict
    add_foreign_key :statistic_facts, [:source_id], :test_cases, [:id], :on_delete => :set_null
  end

  def self.down
    drop_table :statistic_facts
  end
end
