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
class CreateBuildConfigurationDimension < ActiveRecord::Migration
  def self.up
    create_table :build_configuration_dimension do |t|
      t.column :name, :string, :limit => 75, :null => false
      t.column :bootimage_compiler, :string, :limit => 10, :null => false
      t.column :runtime_compiler, :string, :limit => 10, :null => false
      t.column :mmtk_plan, :string, :limit => 50, :null => false
      t.column :assertion_level, :string, :limit => 10, :null => false
      t.column :bootimage_class_inclusion_policy, :string, :limit => 10, :null => false
    end
    add_index :build_configuration_dimension, [:id], :unique => true
    add_index :build_configuration_dimension, [:name]
    add_index :build_configuration_dimension, [:bootimage_compiler]
    add_index :build_configuration_dimension, [:runtime_compiler]
    add_index :build_configuration_dimension, [:mmtk_plan]
    add_index :build_configuration_dimension, [:assertion_level]
    add_index :build_configuration_dimension, [:bootimage_class_inclusion_policy]
  end

  def self.down
    drop_table :build_configuration_dimension
  end
end
