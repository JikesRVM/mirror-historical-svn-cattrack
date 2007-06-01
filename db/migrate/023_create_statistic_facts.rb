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
      t.column :host_id, :integer, :null => false, :on_delete => :restrict, :references => :host_dimensions
      t.column :test_run_id, :integer, :null => false, :on_delete => :restrict, :references => :test_run_dimensions
      t.column :test_configuration_id, :integer, :null => false, :on_delete => :restrict, :references => :test_configuration_dimensions
      t.column :build_configuration_id, :integer, :null => false, :on_delete => :restrict, :references => :build_configuration_dimensions
      t.column :build_target_id, :integer, :null => false, :on_delete => :restrict, :references => :build_target_dimensions
      t.column :test_case_id, :integer, :null => false, :on_delete => :restrict, :references => :test_case_dimensions
      t.column :time_id, :integer, :null => false, :on_delete => :restrict, :references => :time_dimensions
      t.column :revision_id, :integer, :null => false, :on_delete => :restrict, :references => :revision_dimensions
      t.column :statistic_id, :integer, :null => false, :on_delete => :restrict, :references => :statistic_dimensions
      t.column :source_id, :integer, :null => true, :on_delete => :set_null, :references => :test_cases

      t.column :value, :integer, :null => false
    end
  end

  def self.down
    drop_table :statistic_facts
  end
end
