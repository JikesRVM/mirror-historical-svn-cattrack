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
class CreateSummarizers < ActiveRecord::Migration
  def self.up
    create_table :summarizers do |t|
      t.column :name, :string, :limit => 120, :null => false
      t.column :description, :string, :limit => 256, :null => false
      t.column :primary_dimension, :string, :limit => 256, :null => false
      t.column :secondary_dimension, :string, :limit => 256, :null => false
      t.column :function, :string, :limit => 256, :null => false
    end
    add_index :summarizers, [:id], :unique => true
    add_index :summarizers, [:name], :unique => true
  end

  def self.down
    drop_table :summarizers
  end
end
