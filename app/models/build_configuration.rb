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
class BuildConfiguration < ActiveRecord::Base
  validates_reference_exists :test_run_id, TestRun
  validates_length_of :name, :in => 1..75
  validates_uniqueness_of :name, :scope => [:test_run_id]
  validates_inclusion_of :result, :in => %w( SUCCESS FAILURE EXCLUDED OVERTIME )
  validates_not_null :output
  validates_positiveness_of :time
  validates_numericality_of :time, :only_integer => true
  validates_presence_of :test_run_id
  validates_reference_exists :test_run_id, TestRun

  belongs_to :test_run
  has_params :params
  has_many :test_configurations, :dependent => :destroy

  def parent_node
    test_run
  end

  after_save :update_output

  def output=(output)
    @output = output
    @output_modified = true
  end

  def output
    if @output.nil?
      if id
      sql = "SELECT output FROM build_configuration_outputs WHERE build_configuration_id = #{self.id}"
      @output = self.connection.select_value(sql)
      @output_modified = false
    end
  end
    @output
  end

  private

  def update_output
    if @output_modified
      self.connection.execute("DELETE FROM build_configuration_outputs WHERE build_configuration_id = #{id}")
      sql = "INSERT INTO build_configuration_outputs (build_configuration_id,output) VALUES (#{id},#{ActiveRecord::Base.quote_value(@output)})"
      self.connection.execute(sql)
    end
  end
end
