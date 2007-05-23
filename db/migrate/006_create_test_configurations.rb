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
class CreateTestConfigurations < ActiveRecord::Migration
  def self.up
    create_table :test_configurations, :force => true do |t|
      t.column :name, :string, :limit => 75, :null => false
      t.column :test_run_id, :integer, :null => false, :on_delete => :cascade
      t.column :build_run_id, :integer, :null => false, :on_delete => :cascade
    end
    add_index :test_configurations, [:name]
    add_index :test_configurations, [:test_run_id]
    add_index :test_configurations, [:build_run_id]

    create_table :test_configuration_params, :id => false, :force => true do |t|
      t.column :owner_id, :integer, :null => false, :on_delete => :cascade, :references => :test_configurations
      t.column :key, :string, :limit => 50, :null => false
      t.column :value, :string, :limit => 50, :null => false
    end
    add_index :test_configuration_params, [:owner_id, :key], :unique => true
    add_index :test_configuration_params, [:owner_id]
  end

  def self.down
    drop_table :test_configuration_params
    drop_table :test_configurations
  end
end
