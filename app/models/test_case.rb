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
  has_params :statistics
  has_params :params

  auto_validations :except => [:id, :args, :result_explanation]

  validates_inclusion_of :result, :in => %w( SUCCESS FAILURE EXCLUDED OVERTIME )
  validates_non_presence_of :result_explanation, :if => Proc.new {|o| o.result == 'SUCCESS'}
  validates_not_null :output
  validates_positive :time

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
