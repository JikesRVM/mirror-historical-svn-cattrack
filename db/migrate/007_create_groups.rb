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
class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups, :force => true do |t|
      t.column :test_configuration_id, :integer, :null => false, :on_delete => :cascade
      t.column :name, :string, :limit => 75, :null => false
    end
    add_index :groups, [:name]
  end

  def self.down
    drop_table :groups
  end
end
