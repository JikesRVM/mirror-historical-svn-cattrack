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
class AddVariantToTestRun < ActiveRecord::Migration
  def self.up
    # Rework test_run_dimension table to add variant column.
    # MUST be done prior to drop of test_runs to avoid source_id
    # being set to null
    rename_table :test_run_dimension, :old_test_run_dimension
    create_table :test_run_dimension do |t|
      t.column :source_id, :integer, :null => true
      t.column :name, :string, :limit => 75, :null => false
      t.column :variant, :string, :limit => 75, :null => false
    end
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute(<<SQL)
      INSERT INTO test_run_dimension
        SELECT id, source_id, name, name AS variant
          FROM old_test_run_dimension
SQL
    end

    rename_table :test_runs, :old_test_runs
    create_table :test_runs, :force => true do |t|
      t.column :name, :string, :limit => 75, :null => false
      t.column :variant, :string, :limit => 75, :null => false
      t.column :host_id, :integer, :null => false
      t.column :revision, :integer, :null => false
      t.column :occurred_at, :timestamp, :null => false
      t.column :created_at, :timestamp, :null => false
    end
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute(<<SQL)
      INSERT INTO test_runs
        SELECT id, name, name AS variant, host_id, revision, occurred_at, created_at
          FROM old_test_runs
SQL
    end

    drop_table :old_test_run_dimension
    drop_table :old_test_runs

    add_index :test_runs, [:id], :unique => true
    add_index :test_runs, [:host_id, :name, :occurred_at], :unique => true
    add_index :test_runs, [:name]
    add_index :test_runs, [:id, :variant]
    add_index :test_runs, [:variant]
    add_index :test_runs, [:host_id]
    add_index :test_runs, [:revision]
    add_index :test_runs, [:occurred_at]
    add_foreign_key :test_runs, [:host_id], :hosts, [:id], :on_delete => :cascade, :name => "test_runs_host_id_fkey"

    add_index :test_run_dimension, [:id], :unique => true
    add_index :test_run_dimension, [:name]
    add_index :test_run_dimension, [:variant]
    add_index :test_run_dimension, [:source_id]
    add_foreign_key :test_run_dimension, [:source_id], :test_runs, [:id], :on_delete => :set_null

  end

  def self.down
  end
end
