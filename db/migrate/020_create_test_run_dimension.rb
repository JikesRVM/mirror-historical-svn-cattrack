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
class CreateTestRunDimension < ActiveRecord::Migration
  def self.up
    create_table :test_run_dimension do |t|
      t.column :source_id, :integer, :null => true
      t.column :name, :string, :limit => 75, :null => false
    end
    add_index :test_run_dimension, [:id], :unique => true
    add_index :test_run_dimension, [:name]
    add_index :test_run_dimension, [:source_id]
    add_foreign_key :test_run_dimension, [:source_id], :test_cases, [:id], :on_delete => :set_null
  end

  def self.down
    drop_table :test_run_dimension
  end
end
