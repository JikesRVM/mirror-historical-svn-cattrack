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
class CreateBuildConfigurations < ActiveRecord::Migration
  def self.up
    create_table :build_configurations, :force => true do |t|
      t.column :name, :string, :limit => 75, :null => false
    end

    create_table :build_configuration_params, :id => false, :force => true do |t|
      t.column :owner_id, :integer, :null => false, :on_delete => :cascade, :references => :build_configurations
      t.column :key, :string, :limit => 50, :null => false
      t.column :value, :string, :limit => 256, :null => false
    end
    add_index :build_configuration_params, [:owner_id, :key], :unique => true
    add_index :build_configuration_params, [:owner_id]
    add_index :build_configuration_params, [:owner_id, :key, :value]
  end

  def self.down
    drop_table :build_configuration_params
    drop_table :build_configurations
  end
end
