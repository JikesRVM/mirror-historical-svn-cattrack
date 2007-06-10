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
class CreateRevisionDimension < ActiveRecord::Migration
  def self.up
    create_table :revision_dimension do |t|
      t.column :revision, :integer, :null => false
    end
    add_index :revision_dimension, [:id], :unique => true
    add_index :revision_dimension, [:revision]
  end

  def self.down
    drop_table :revision_dimension
  end
end
