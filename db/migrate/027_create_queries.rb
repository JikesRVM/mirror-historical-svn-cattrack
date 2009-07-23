#
#  This file is part of the Jikes RVM project (http://jikesrvm.org).
#
#  This file is licensed to You under the Eclipse Public License (EPL);
#  You may not use this file except in compliance with the License. You
#  may obtain a copy of the License at
#
#      http://www.opensource.org/licenses/cpl1.0.php
#
#  See the COPYRIGHT.txt file distributed with this work for information
#  regarding copyright ownership.
#
class CreateQueries < ActiveRecord::Migration
  def self.up
    create_table :queries do |t|
      t.column :name, :string, :limit => 120, :null => false
      t.column :description, :string, :limit => 256, :null => false
      t.column :primary_dimension, :string, :limit => 256, :null => false
      t.column :secondary_dimension, :string, :limit => 256, :null => false
      t.column :measure_id, :integer, :null => false
      t.column :filter_id, :integer, :null => false
    end
    add_index :queries, [:id], :unique => true
    add_index :queries, [:name], :unique => true
    add_foreign_key :queries, [:measure_id], :measures, [:id], :on_delete => :cascade
    add_foreign_key :queries, [:filter_id], :filters, [:id], :on_delete => :cascade
  end

  def self.down
    drop_table :queries
  end
end
