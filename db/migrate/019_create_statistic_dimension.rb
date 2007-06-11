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
class CreateStatisticDimension < ActiveRecord::Migration
  def self.up
    create_table :statistic_dimension do |t|
      t.column :name, :string, :limit => 75, :null => false
    end
    add_index :statistic_dimension, [:id], :unique => true
    add_index :statistic_dimension, [:name], :unique => true
  end

  def self.down
    drop_table :statistic_dimension
  end
end
