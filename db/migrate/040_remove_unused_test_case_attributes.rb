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
class RemoveUnusedTestCaseAttributes < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute(<<SQL)
UPDATE test_cases
  SET command = 'cd ' || working_directory || ' && ' || command
SQL
      remove_column :test_cases, :working_directory
      remove_column :test_cases, :classname
      remove_column :test_cases, :args
    end
  end

  def self.down
  end
end
