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
class CreateTestCaseCompilations < ActiveRecord::Migration
  def self.up
    create_table :test_case_compilations do |t|
        t.column :test_case_id, :integer, :null => false
        t.column :result, :string, :limit => 15, :null => false
        t.column :exit_code, :integer, :null => false
        t.column :time, :integer, :null => false
    end
    add_index :test_case_compilations, [:id], :unique => true
    add_index :test_case_compilations, [:test_case_id], :unique => true
    add_index :test_case_compilations, [:result]
    add_foreign_key :test_case_compilations, [:test_case_id], :test_cases, [:id], :on_delete => :cascade

    create_table :test_case_compilation_outputs, :id => false do |t|
      t.column :owner_id, :integer, :null => false
      t.column :output, :text, :null => false
    end
    add_index :test_case_compilation_outputs, [:owner_id], :unique => true
    add_foreign_key :test_case_compilation_outputs, [:owner_id], :test_case_compilations, [:id], :on_delete => :cascade
  end

  def self.down
    drop_table :test_case_compilations
    drop_table :test_case_compilation_outputs
  end
end
