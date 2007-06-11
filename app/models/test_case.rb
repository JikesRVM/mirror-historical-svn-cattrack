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
class TestCase < ActiveRecord::Base
  validates_length_of :name, :in => 1..75
  validates_uniqueness_of :name, :scope => [:group_id]
  validates_presence_of :group_id
  validates_reference_exists :group_id, Group
  validates_length_of :classname, :in => 1..75
  validates_length_of :working_directory, :in => 1..256
  validates_length_of :result_explanation, :in => 0..256
  validates_presence_of :command
  validates_numericality_of :exit_code, :only_integer => true
  validates_numericality_of :time, :only_integer => true
  validates_inclusion_of :result, :in => %w( SUCCESS FAILURE EXCLUDED OVERTIME )
  validates_non_presence_of :result_explanation, :if => Proc.new {|o| o.result == 'SUCCESS'}
  validates_not_null :output
  validates_positiveness_of :time

  belongs_to :group
  has_params :statistics
  has_params :params

  after_save :update_output

  def output=(output)
    @output = output
    @output_modified = true
  end

  def output
    if @output.nil?
      if id
        sql = "SELECT output FROM test_case_outputs WHERE test_case_id = #{self.id}"
        @output = self.connection.select_value(sql)
        @output_modified = false
      end
    end
    @output
  end

  def parent_node
    group
  end

  private

  def update_output
    if @output_modified
      self.connection.execute("DELETE FROM test_case_outputs WHERE test_case_id = #{id}")
      sql = "INSERT INTO test_case_outputs (test_case_id,output) VALUES (#{id},#{ActiveRecord::Base.quote_value(@output)})"
      self.connection.execute(sql)
    end
  end
end
