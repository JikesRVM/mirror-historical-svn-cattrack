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
class CreateBuildRuns < ActiveRecord::Migration
  def self.up
    create_table :build_runs, :force => true do |t|
      t.column :build_configuration_id, :integer, :null => false, :on_delete => :cascade
      t.column :result, :string, :limit => 15, :null => false
      t.column :time, :integer, :null => false
    end

    create_table :build_run_outputs, :id => false, :force => true do |t|
      t.column :build_run_id, :integer, :null => false, :on_delete => :cascade
      t.column :output, :text, :null => false
    end
    add_index :build_run_outputs, [:build_run_id], :unique => true

  end

  def self.down
    drop_table :build_run_outputs
    drop_table :build_runs
  end
end