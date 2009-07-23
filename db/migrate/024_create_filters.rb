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
class CreateFilters < ActiveRecord::Migration
  def self.up
    create_table :filters do |t|
      t.column :name, :string, :limit => 75, :null => false
      t.column :description, :string, :limit => 256, :null => false
    end
    add_index :filters, [:id], :unique => true
    add_index :filters, [:name], :unique => true

    create_table :filter_params do |t|
      t.column :owner_id, :integer, :null => false
      t.column :key, :string, :limit => 75, :null => false
      t.column :value, :string, :limit => 256, :null => false
    end
    add_index :filter_params, [:owner_id, :key]
    add_index :filter_params, [:owner_id]
    add_index :filter_params, [:owner_id, :key, :value]
  end

  def self.down
    drop_table :filter_params
    drop_table :filters
  end
end
