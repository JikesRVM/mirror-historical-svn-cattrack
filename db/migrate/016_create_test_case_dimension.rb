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
class CreateTestCaseDimension < ActiveRecord::Migration
  def self.up
    create_table :test_case_dimension do |t|
      t.column :group, :string, :limit => 75, :null => false
      t.column :name, :string, :limit => 75, :null => false
    end
    add_index :test_case_dimension, [:id], :unique => true
    add_index :test_case_dimension, [:name, :group], :unique => true
    add_index :test_case_dimension, [:name]
    add_index :test_case_dimension, [:group]
  end

  def self.down
    drop_table :test_case_dimension
  end
end
