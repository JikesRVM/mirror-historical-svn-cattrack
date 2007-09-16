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
class AddStatisticsToTestCase < ActiveRecord::Migration
  def self.up
    create_table :test_case_statistics, :id => false do |t|
      t.column :owner_id, :integer, :null => false
      t.column :key, :string, :limit => 50, :null => false
      t.column :value, :float, :null => false
    end
    add_index :test_case_statistics, [:owner_id, :key], :unique => true, :name => 'tcn_ok'
    add_index :test_case_statistics, [:owner_id], :name => 'tcn_o'
    add_index :test_case_statistics, [:owner_id, :key, :value], :name => 'tcn_okv'
    add_foreign_key :test_case_statistics, [:owner_id], :test_cases, [:id], :on_delete => :cascade
  end

  def self.down
  end
end
