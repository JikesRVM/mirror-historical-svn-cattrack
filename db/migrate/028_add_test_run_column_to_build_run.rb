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
class AddTestRunColumnToBuildRun < ActiveRecord::Migration
  class BuildRun < ActiveRecord::Base
    auto_relations :only => []
  end

  class TestConfiguration < ActiveRecord::Base
    auto_relations :only => []
  end

  def self.up
    add_column(:build_runs, :test_run_id, :integer, :default => -1, :null => false, :references => nil)
    BuildRun.reset_column_information

    BuildRun.find(:all).each do |b|
      tc = TestConfiguration.find_by_build_run_id(b.id)
      b.test_run_id = tc.test_run_id
      b.save!
    end
    add_foreign_key(:build_runs, :test_run_id, :test_runs, :id, :on_delete => :cascade)
  end

  def self.down
    remove_column(:build_runs, :test_run_id)
  end
end
