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
class Tdm::TestCase < ActiveRecord::Base
  validates_format_of :name, :with => /^[\.\-a-zA-Z_0-9]+$/
  validates_length_of :name, :in => 1..75
  validates_uniqueness_of :name, :scope => [:group_id]
  validates_presence_of :group_id
  validates_reference_exists :group_id, Tdm::Group
  validates_presence_of :command

  belongs_to :group
  has_many :test_case_executions, :order => 'name', :dependent => :destroy
  has_many :successes, :class_name => 'Tdm::TestCaseExecution', :order => 'name', :conditions => "test_case_executions.result = 'SUCCESS'"
  has_params :params

  has_params :statistics
  
  include TestCaseContainer

  def parent_node
    group
  end
end
