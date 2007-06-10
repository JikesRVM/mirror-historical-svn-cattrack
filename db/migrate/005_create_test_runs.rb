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
class CreateTestRuns < ActiveRecord::Migration
  def self.up
    create_table :test_runs, :force => true do |t|
      t.column :name, :string, :limit => 75, :null => false
      t.column :host_id, :integer, :null => false
      t.column :revision, :integer, :null => false
      t.column :occured_at, :timestamp, :null => false
      t.column :created_at, :timestamp, :null => false
    end
    add_index :test_runs, [:id], :unique => true
    add_index :test_runs, [:host_id, :name, :occured_at], :unique => true
    add_index :test_runs, [:name]
    add_index :test_runs, [:host_id]
    add_index :test_runs, [:revision]
    add_index :test_runs, [:occured_at]
    add_foreign_key :test_runs, [:host_id], :hosts, [:id], :on_delete => :cascade, :name => "test_runs_host_id_fkey"
  end

  def self.down
    drop_table :test_runs
  end
end
