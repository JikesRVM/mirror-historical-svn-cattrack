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
      t.column :build_configuration_id, :integer, :null => false
    end
    add_index :test_configurations, [:id], :unique => true
    add_index :test_configurations, [:name, :build_configuration_id], :unique => true
    add_index :test_configurations, [:name]
    add_index :test_configurations, [:build_configuration_id]
    add_foreign_key :test_configurations, [:build_configuration_id], :build_configurations, [:id], :on_delete => :cascade

    create_table :test_configuration_params, :id => false, :force => true do |t|
      t.column :owner_id, :integer, :null => false
      t.column :key, :string, :limit => 50, :null => false
      t.column :value, :string, :limit => 256, :null => false
    end
    add_index :test_configuration_params, [:owner_id, :key], :unique => true
    add_index :test_configuration_params, [:owner_id]
    add_index :test_configuration_params, [:owner_id, :key, :value]
    add_foreign_key :test_configuration_params, [:owner_id], :test_configurations, [:id], :on_delete => :cascade
  end

  def self.down
    drop_table :test_configuration_params
    drop_table :test_configurations
  end
end
