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
class CreateTimeDimension < ActiveRecord::Migration
  def self.up
    create_table :time_dimension do |t|
      t.column :year, :integer, :null => false
      t.column :month, :integer, :null => false
      t.column :week, :integer, :null => false
      t.column :day_of_year, :integer, :null => false
      t.column :day_of_month, :integer, :null => false
      t.column :day_of_week, :integer, :null => false
      t.column :time, :timestamp, :null => false
    end
    add_index :time_dimension, [:id], :unique => true
    add_index :time_dimension, [:year]
    add_index :time_dimension, [:month]
    add_index :time_dimension, [:week]
    add_index :time_dimension, [:day_of_year]
    add_index :time_dimension, [:day_of_month]
    add_index :time_dimension, [:day_of_week]
    add_index :time_dimension, [:time]
  end

  def self.down
    drop_table :time_dimension
  end
end
