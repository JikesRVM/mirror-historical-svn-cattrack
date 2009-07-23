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
class CreateBuildTargetDimension < ActiveRecord::Migration
  def self.up
    create_table :build_target_dimension do |t|
      t.column :name, :string, :limit => 75, :null => false
      t.column :arch, :string, :limit => 10, :null => false
      t.column :address_size, :integer, :null => false
      t.column :operating_system, :string, :limit => 50, :null => false
    end
    add_index :build_target_dimension, [:id], :unique => true
    add_index :build_target_dimension, [:name]
    add_index :build_target_dimension, [:arch]
    add_index :build_target_dimension, [:address_size]
    add_index :build_target_dimension, [:operating_system]
  end

  def self.down
    drop_table :build_target_dimension
  end
end
