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
class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.column :test_configuration_id, :integer, :null => false
      t.column :name, :string, :limit => 75, :null => false
    end
    add_index :groups, [:id], :unique => true
    add_index :groups, [:test_configuration_id, :name], :unique => true
    add_index :groups, [:name]
    add_foreign_key :groups, [:test_configuration_id], :test_configurations, [:id], :on_delete => :cascade
  end

  def self.down
    drop_table :groups
  end
end
