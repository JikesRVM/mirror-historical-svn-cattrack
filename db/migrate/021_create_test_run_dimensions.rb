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
class CreateTestRunDimensions < ActiveRecord::Migration
  def self.up
    create_table :test_run_dimensions do |t|
      t.column :source_id, :integer, :null => true, :on_delete => :set_null, :references => :test_cases
    end
  end

  def self.down
    drop_table :test_run_dimensions
  end
end
