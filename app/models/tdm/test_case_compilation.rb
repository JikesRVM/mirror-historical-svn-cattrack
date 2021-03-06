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
class Tdm::TestCaseCompilation < ActiveRecord::Base
  validates_presence_of :test_case_id
  validates_reference_exists :test_case_id, Tdm::TestCase
  validates_numericality_of :time, :only_integer => true
  validates_not_null :output
  validates_positiveness_of :time

  belongs_to :test_case

  after_save :update_output

  def parent_node
    test_case
  end

  def output=(output)
    @output = output
    @output_modified = true
  end

  def output
    if @output.nil?
      if id
        sql = "SELECT output FROM test_case_compilation_outputs WHERE owner_id = #{self.id}"
        @output = self.connection.select_value(sql)
        @output_modified = false
      end
    end
    @output
  end

  private

  def update_output
    if @output_modified
      self.connection.execute("DELETE FROM test_case_compilation_outputs WHERE owner_id = #{id}")
      sql = "INSERT INTO test_case_compilation_outputs (owner_id,output) VALUES (#{id},#{ActiveRecord::Base.quote_value(@output)})"
      self.connection.execute(sql)
    end
  end
end
