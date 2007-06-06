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
class BuildRun < ActiveRecord::Base
  validates_inclusion_of :result, :in => %w( SUCCESS FAILURE EXCLUDED OVERTIME )
  validates_not_null :output
  validates_positive :time

  def label
    build_configuration.name
  end

  after_save :update_output
  after_destroy :remove_orphaned_build_configurations

  def output=(output)
    @output = output
    @output_modified = true
  end

  def output
    if @output.nil?
      if id
      sql = "SELECT output FROM build_run_outputs WHERE build_run_id = #{self.id}"
      @output = self.connection.select_value(sql)
      @output_modified = false
    end
  end
    @output
  end

  def parent_node
    test_run
  end

  private

  def remove_orphaned_build_configurations
    build_configuration = BuildConfiguration.find(:first, build_configuration_id)
    build_configuration.destroy if (build_configuration and build_configuration.build_runs.empty?)
  end

  def update_output
    if @output_modified
      self.connection.execute("DELETE FROM build_run_outputs WHERE build_run_id = #{id}")
      sql = "INSERT INTO build_run_outputs (build_run_id,output) VALUES (#{id},#{ActiveRecord::Base.quote_value(@output)})"
      self.connection.execute(sql)
    end
  end
end
