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
class CreateSystemSettings < ActiveRecord::Migration
  def self.up
    create_table :system_settings do |t|
      t.column :name, :string, :null => false, :limit => 255
      t.column :value, :text, :null => false
    end

    add_index :system_settings, [:name], :unique => true
  end

  def self.down
    drop_table :system_settings
  end
end
