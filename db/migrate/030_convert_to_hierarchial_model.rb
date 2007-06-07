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
class ConvertToHierarchialModel < ActiveRecord::Migration
  class BuildConfiguration < ActiveRecord::Base
  end

  class BuildRun < ActiveRecord::Base
  end

  def self.up
    ActiveRecord::Base.transaction do
      add_column(:build_configurations, :test_run_id, :integer, :default => -1, :null => false, :references => nil)
      BuildConfiguration.reset_column_information

      BuildConfiguration.find(:all).each do |b|
        br = BuildRun.find_by_build_configuration_id(b.id)
        if br
          b.test_run_id = br.test_run_id
          b.save!
        else
          b.destroy
        end
      end

      add_foreign_key :build_configurations, :test_run_id, :test_runs, :id, :on_delete => :cascade
      add_index :build_configurations, [:test_run_id, :name], :unique => true

      remove_column :build_runs, :test_run_id
      remove_column :test_configurations, :test_run_id
      add_index :test_configurations, [:build_run_id, :name], :unique => true
    end
  end

  def self.down
  end
end
