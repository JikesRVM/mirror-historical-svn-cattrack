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
class CreateMeasures < ActiveRecord::Migration
  def self.up
    create_table :measures do |t|
      t.column :name, :string, :limit => 120, :null => false
      t.column :sql, :string, :limit => 512, :null => false
      t.column :joins, :string, :limit => 50, :null => false
      t.column :grouping, :string, :limit => 50, :null => false
    end
    add_index :measures, [:id], :unique => true
    add_index :measures, [:name], :unique => true
  end

  def self.down
    drop_table :measures
  end
end
