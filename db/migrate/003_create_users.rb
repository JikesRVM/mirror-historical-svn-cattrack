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
class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :username, :string, :limit => 40, :null => false
      t.column :password, :string, :limit => 40, :null => false
      t.column :salt, :string, :limit => 40, :null => false
      t.column :admin, :boolean, :null => false
      t.column :active, :boolean, :null => false
    end
    add_index :users, [:id], :unique => true
    add_index :users, [:username], :unique => true
    add_index :users, [:username, :password, :active]
  end

  def self.down
    drop_table :users
  end
end
