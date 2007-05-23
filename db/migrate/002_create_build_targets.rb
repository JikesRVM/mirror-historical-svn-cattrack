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
class CreateBuildTargets < ActiveRecord::Migration
  def self.up
    create_table :build_targets, :force => true do |t|
      t.column :name, :string, :limit => 75, :null => false
    end
    add_index :build_targets, [:name], :unique => true

    create_table :build_target_params, :id => false, :force => true do |t|
      t.column :owner_id, :integer, :null => false, :on_delete => :cascade, :references => :build_targets
      t.column :key, :string, :limit => 50, :null => false
      t.column :value, :string, :limit => 50, :null => false
    end
    add_index :build_target_params, [:owner_id, :key], :unique => true
    add_index :build_target_params, [:owner_id]
  end

  def self.down
    drop_table :build_target_params
    drop_table :build_targets
  end
end
