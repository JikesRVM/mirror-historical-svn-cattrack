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
class CreateTimeDimensions < ActiveRecord::Migration
  def self.up
    create_table :time_dimensions do |t|
      t.column :year, :integer, :null => false
      t.column :month, :integer, :null => false
      t.column :week, :integer, :null => false
      t.column :day_of_year, :integer, :null => false
      t.column :day_of_month, :integer, :null => false
      t.column :day_of_week, :integer, :null => false
      t.column :time, :timestamp, :null => false
    end
    add_index :time_dimensions, [:id], :unique => true
    add_index :time_dimensions, [:year]
    add_index :time_dimensions, [:month]
    add_index :time_dimensions, [:week]
    add_index :time_dimensions, [:day_of_year]
    add_index :time_dimensions, [:day_of_month]
    add_index :time_dimensions, [:day_of_week]
    add_index :time_dimensions, [:time]
  end

  def self.down
    drop_table :time_dimensions
  end
end
